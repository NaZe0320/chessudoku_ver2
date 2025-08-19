import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/application/intents/game_intent.dart';
import 'package:chessudoku/application/states/game_state.dart';
import 'package:chessudoku/domain/entities/game_board.dart';
import 'package:chessudoku/domain/entities/sudoku_board.dart';
import 'package:chessudoku/domain/entities/position.dart';
import 'package:chessudoku/domain/entities/cell_content.dart';
import 'package:chessudoku/core/enums/chess_piece.dart';
import 'package:chessudoku/domain/entities/checkpoint.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/repositories/puzzle_record_repository.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/application/notifiers/game_settings_notifier.dart';
import 'package:chessudoku/data/models/puzzle_record.dart';
import 'package:chessudoku/data/models/saved_game_data.dart';

class GameNotifier extends BaseNotifier<GameIntent, GameState>
    with WidgetsBindingObserver {
  Timer? _timer;
  final GameSaveRepository _gameSaveRepository;
  final PuzzleRecordRepository _puzzleRecordRepository;
  bool _wasTimerRunningBeforePause = false; // 앱이 백그라운드로 가기 전 타이머 상태
  Difficulty? _currentDifficulty; // 현재 게임 난이도

  // 메모 히스토리 묶기 관련 변수들
  Position? _lastMemoPosition; // 마지막 메모 입력 위치
  bool _isMemoGroupActive = false; // 메모 그룹 활성화 상태

  final GameSettingsNotifier _settings;

  GameNotifier(
    this._gameSaveRepository,
    this._puzzleRecordRepository,
    this._settings,
  ) : super(const GameState()) {
    // 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  /// 게임 상태 자동 저장
  Future<void> autoSave() async {
    developer.log('자동 저장 시작', name: 'GameNotifier');
    if (state.currentBoard != null && _currentDifficulty != null) {
      developer.log('저장 조건 충족 - 보드 존재, 난이도: $_currentDifficulty',
          name: 'GameNotifier');

      // SavedGameData 생성
      final savedGameData = SavedGameData(
        board: state.currentBoard!,
        elapsedSeconds: state.elapsedSeconds,
        history: state.history,
        redoHistory: state.redoHistory,
        difficulty: _currentDifficulty!,
        savedAt: DateTime.now(),
        checkpoints: state.checkpoints,
      );

      // 난이도별 저장 사용
      final success = await _gameSaveRepository.saveGameByDifficulty(
          savedGameData, _currentDifficulty!);
      developer.log('자동 저장 결과: $success', name: 'GameNotifier');
    } else {
      developer.log(
          '저장 조건 불충족 - 보드: ${state.currentBoard != null}, 난이도: $_currentDifficulty',
          name: 'GameNotifier');
    }
  }

  /// 현재 게임 난이도 설정 (MainScreen에서 호출)
  void setCurrentDifficulty(Difficulty difficulty) {
    _currentDifficulty = difficulty;
    developer.log('현재 게임 난이도 설정: $difficulty', name: 'GameNotifier');
  }

  @override
  void onIntent(GameIntent intent) {
    switch (intent) {
      case StartGameIntent():
        _handleStartGame(intent.preparedBoard);
      case SelectCellIntent():
        _handleSelectCell(intent.position);
      case InputNumberIntent():
        _handleInputNumber(intent.number);
      case ToggleNoteIntent():
        _handleToggleNote(intent.number);
      case ToggleNoteModeIntent():
        _handleToggleNoteMode();
      case ClearCellIntent():
        _handleClearCell();
      case CheckErrorsIntent():
        _handleCheckErrors();
      case CheckGameCompletionIntent():
        _handleCheckGameCompletion();
      case HideCompletionDialogIntent():
        _handleHideCompletionDialog();
      case CreateCheckpointIntent():
        _handleCreateCheckpoint(intent.checkpointId);
      case RestoreCheckpointIntent():
        _handleRestoreCheckpoint(intent.checkpointId);
      case DeleteCheckpointIntent():
        _handleDeleteCheckpoint(intent.checkpointId);
      case StartTimerIntent():
        _handleStartTimer();
      case PauseTimerIntent():
        _handlePauseTimer();
      case ResetTimerIntent():
        _handleResetTimer();
      case UndoIntent():
        _handleUndo();
      case RedoIntent():
        _handleRedo();
      case LoadSavedGameIntent():
        _handleLoadSavedGame();
      case AutoFillNotesIntent():
        _handleAutoFillNotes();
      case ShowChessConstraintIntent():
        _handleShowChessConstraint(intent.position);
    }
  }

  /// 준비된 게임 데이터로 게임 시작
  void _handleStartGame(GameBoard preparedBoard) {
    developer.log('준비된 게임 데이터로 게임 시작', name: 'GameNotifier');

    // 준비된 게임 보드의 난이도를 현재 난이도로 설정
    _currentDifficulty = preparedBoard.difficulty;
    developer.log('준비된 게임 보드의 난이도를 현재 난이도로 설정: $_currentDifficulty',
        name: 'GameNotifier');

    // 선택된 셀을 초기화한 보드 생성
    final boardWithoutSelection = preparedBoard.selectCell(null);

    state = state.copyWith(
      currentBoard: boardWithoutSelection,
      history: [],
      redoHistory: [],
      canUndo: false,
      canRedo: false,
      elapsedSeconds: 0,
      isPaused: false,
      isGameCompleted: false,
      showCompletionDialog: false,
      checkpoints: {}, // 새 게임 시작 시 체크포인트 초기화
      selectedCellContent: null, // 선택된 셀 내용 초기화
    );

    // 타이머 시작
    _handleStartTimer();
    developer.log('게임 시작 완료', name: 'GameNotifier');
  }

  /// 저장된 게임 데이터로 게임 시작 (GamePreparationNotifier에서 호출)
  void handleStartSavedGameFromPreparation(SavedGameData savedGameData) {
    developer.log('저장된 게임 데이터로 게임 시작 (준비 단계에서)', name: 'GameNotifier');
    developer.log('저장된 경과 시간: ${savedGameData.elapsedSeconds}초',
        name: 'GameNotifier');

    // 현재 난이도 설정
    _currentDifficulty = savedGameData.difficulty;

    // 선택된 셀을 초기화한 보드 생성
    final boardWithoutSelection = savedGameData.board.selectCell(null);

    state = state.copyWith(
      currentBoard: boardWithoutSelection,
      history: savedGameData.history,
      redoHistory: savedGameData.redoHistory,
      canUndo: savedGameData.history.isNotEmpty,
      canRedo: savedGameData.redoHistory.isNotEmpty,
      elapsedSeconds: savedGameData.elapsedSeconds,
      isPaused: false,
      isGameCompleted: false,
      showCompletionDialog: false,
      checkpoints: savedGameData.checkpoints,
      selectedCellContent: null, // 선택된 셀 내용 초기화
    );

    // 타이머 시작
    _handleStartTimer();
    developer.log('저장된 게임 시작 완료', name: 'GameNotifier');
  }

  /// 저장된 게임 로드
  void _handleLoadSavedGame() {
    developer.log('저장된 게임 로드 시작', name: 'GameNotifier');

    try {
      final savedGameData = _gameSaveRepository.loadCurrentGame();
      if (savedGameData != null) {
        developer.log('저장된 게임 데이터 로드 성공', name: 'GameNotifier');
        developer.log('저장된 경과 시간: ${savedGameData.elapsedSeconds}초',
            name: 'GameNotifier');
        developer.log('현재 설정된 난이도: $_currentDifficulty', name: 'GameNotifier');
        developer.log('저장된 게임의 난이도: ${savedGameData.difficulty}',
            name: 'GameNotifier');

        // MainNotifier에서 설정한 난이도가 있으면 우선 사용
        if (_currentDifficulty != null) {
          developer.log('MainNotifier에서 설정한 난이도 사용: $_currentDifficulty',
              name: 'GameNotifier');
          // 난이도별 저장된 게임 데이터로 교체
          final difficultySpecificData =
              _gameSaveRepository.getSavedGameByDifficulty(_currentDifficulty!);
          if (difficultySpecificData != null) {
            handleStartSavedGameFromPreparation(difficultySpecificData);
          } else {
            // 해당 난이도의 저장된 게임이 없으면 기존 데이터 사용
            developer.log('해당 난이도의 저장된 게임이 없어 기존 데이터 사용', name: 'GameNotifier');
            handleStartSavedGameFromPreparation(savedGameData);
          }
        } else {
          // MainNotifier에서 난이도가 설정되지 않았으면 저장된 게임의 난이도 사용
          developer.log('MainNotifier에서 난이도가 설정되지 않아 저장된 게임의 난이도 사용',
              name: 'GameNotifier');
          // 저장된 게임의 난이도를 현재 난이도로 설정
          _currentDifficulty = savedGameData.difficulty;
          developer.log('저장된 게임의 난이도를 현재 난이도로 설정: $_currentDifficulty',
              name: 'GameNotifier');
          handleStartSavedGameFromPreparation(savedGameData);
        }
      } else {
        developer.log('저장된 게임 데이터가 없습니다.', name: 'GameNotifier');
      }
    } catch (e) {
      developer.log('저장된 게임 로드 실패: $e', name: 'GameNotifier');
    }
  }

  void _handleSelectCell(position) {
    final currentBoard = state.currentBoard;
    if (currentBoard != null) {
      // 메모 그룹 완료
      _completeMemoGroup();

      final newBoard = currentBoard.selectCell(position);

      // 선택된 셀의 내용을 selectedCellContent에 저장
      CellContent? selectedCellContent;
      if (newBoard.selectedCell != null) {
        selectedCellContent =
            newBoard.board.getCellContent(newBoard.selectedCell!);
        // 초기값인 경우 selectedCellContent를 null로 설정
        if (selectedCellContent?.isInitial == true) {
          selectedCellContent = null;
        }
      }

      state = state.copyWith(
        currentBoard: newBoard,
        selectedCellContent: selectedCellContent,
      );
    }
  }

  void _handleInputNumber(int number) {
    final currentBoard = state.currentBoard;
    final selectedCell = currentBoard?.selectedCell;

    if (currentBoard == null || selectedCell == null) return;

    // 선택된 셀의 현재 내용 가져오기
    final currentContent = currentBoard.board.getCellContent(selectedCell);

    // 초기값인 경우 수정 불가
    if (currentContent?.isInitial == true) return;

    // 체스 기물이 있는 칸에는 숫자 입력 불가
    if (currentContent?.chessPiece != null) return;

    if (currentBoard.isNoteMode) {
      // 메모 모드인 경우 메모 토글
      _toggleNoteForCell(selectedCell, number);
    } else {
      // 일반 모드인 경우 숫자 입력/제거
      _inputNumberToCell(selectedCell, number);
    }
  }

  void _handleToggleNote(int number) {
    final currentBoard = state.currentBoard;
    final selectedCell = currentBoard?.selectedCell;

    if (currentBoard == null || selectedCell == null) return;

    _toggleNoteForCell(selectedCell, number);
  }

  void _toggleNoteForCell(Position position, int number) {
    final currentBoard = state.currentBoard!;
    final currentContent = currentBoard.board.getCellContent(position);

    // 초기값인 경우 메모 불가
    if (currentContent?.isInitial == true) return;

    // 체스 기물이 있는 칸에는 메모 입력 불가
    if (currentContent?.chessPiece != null) return;

    // 메모 히스토리 묶기 처리
    _handleMemoHistoryGrouping(position);

    // 숫자가 이미 입력된 경우 숫자를 지우고 메모로 전환
    if (currentContent?.number != null) {
      // 기존 메모들을 유지하면서 새로운 메모 토글
      final existingNotes = currentContent?.notes ?? {};
      final newNotes = Set<int>.from(existingNotes);
      if (newNotes.contains(number)) {
        newNotes.remove(number); // 이미 있으면 제거
      } else {
        newNotes.add(number); // 없으면 추가 (수동 메모는 제약 미적용)
      }

      final newContent = CellContent(
        notes: newNotes, // 기존 메모 유지하면서 새로운 메모 토글
        chessPiece: currentContent?.chessPiece, // 기존 체스 기물 유지
        isInitial: false, // 사용자 입력
      );

      final newBoard = currentBoard.board.setCellContent(position, newContent);

      // 메모 입력 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );

      state = state.copyWith(currentBoard: updatedGameBoard);

      // selectedCellContent 업데이트
      state = state.copyWith(selectedCellContent: newContent);
    } else {
      // 기존 메모 토글 (수동 메모는 제약 미적용)
      final newContent =
          currentContent?.toggleNote(number) ?? CellContent(notes: {number});

      final newBoard = currentBoard.board.setCellContent(position, newContent);

      // 메모 입력 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );

      state = state.copyWith(currentBoard: updatedGameBoard);

      // selectedCellContent 업데이트
      state = state.copyWith(selectedCellContent: newContent);
    }
  }

  void _inputNumberToCell(Position position, int number) {
    final currentBoard = state.currentBoard!;
    final currentContent = currentBoard.board.getCellContent(position);

    // 초기값인 경우 수정 불가
    if (currentContent?.isInitial == true) return;

    // 메모 그룹 완료
    _completeMemoGroup();

    // 히스토리에 현재 상태 저장
    _saveToHistory();

    // 이미 같은 숫자가 입력되어 있으면 제거
    if (currentContent?.number == number) {
      // 숫자만 제거하고 메모는 유지
      final newContent = CellContent(
        notes: currentContent?.notes ?? {},
        chessPiece: currentContent?.chessPiece, // 기존 체스 기물 유지
        isInitial: false, // 사용자 입력
      );

      final newBoard = currentBoard.board.setCellContent(position, newContent);

      // 숫자 제거 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );

      state = state.copyWith(currentBoard: updatedGameBoard);

      // selectedCellContent 업데이트
      state = state.copyWith(selectedCellContent: newContent);
    } else {
      // 새로운 숫자 입력 (메모는 유지)
      final newContent = CellContent(
        number: number,
        notes: currentContent?.notes ?? {}, // 기존 메모 유지
        chessPiece: currentContent?.chessPiece, // 기존 체스 기물 유지
        isInitial: false, // 사용자 입력
      );

      // 숫자 배치
      var newBoard = currentBoard.board.setCellContent(position, newContent);

      // 자동 메모 삭제: 켜져 있으면 동일 행/열/블록에서 입력한 숫자 메모 제거
      if (_settings.state.autoNoteClear) {
        final cells = Map<Position, CellContent>.from(newBoard.cells);
        for (int i = 0; i < 9; i++) {
          // 같은 행
          final pRow = Position(row: position.row, col: i);
          if (pRow != position) {
            final c = cells[pRow];
            if (c != null && c.number == null && c.notes.contains(number)) {
              final newNotes = Set<int>.from(c.notes)..remove(number);
              cells[pRow] = CellContent(
                number: null,
                notes: newNotes,
                chessPiece: c.chessPiece,
                isInitial: c.isInitial,
              );
            }
          }

          // 같은 열
          final pCol = Position(row: i, col: position.col);
          if (pCol != position) {
            final c = cells[pCol];
            if (c != null && c.number == null && c.notes.contains(number)) {
              final newNotes = Set<int>.from(c.notes)..remove(number);
              cells[pCol] = CellContent(
                number: null,
                notes: newNotes,
                chessPiece: c.chessPiece,
                isInitial: c.isInitial,
              );
            }
          }
        }

        // 같은 3x3 블록
        final blockRow = position.row ~/ 3;
        final blockCol = position.col ~/ 3;
        for (int r = blockRow * 3; r < blockRow * 3 + 3; r++) {
          for (int cIdx = blockCol * 3; cIdx < blockCol * 3 + 3; cIdx++) {
            final p = Position(row: r, col: cIdx);
            if (p == position) continue;
            final c = cells[p];
            if (c != null && c.number == null && c.notes.contains(number)) {
              final newNotes = Set<int>.from(c.notes)..remove(number);
              cells[p] = CellContent(
                number: null,
                notes: newNotes,
                chessPiece: c.chessPiece,
                isInitial: c.isInitial,
              );
            }
          }
        }

        newBoard = newBoard.copyWith(cells: cells);
      }

      // 숫자 입력 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );

      state = state.copyWith(currentBoard: updatedGameBoard);

      // selectedCellContent 업데이트
      state = state.copyWith(selectedCellContent: newContent);
    }

    // 게임 완료 체크
    _handleCheckGameCompletion();
  }

  // 자동 메모 비활성화에 따라 사용되지 않음

  void _handleToggleNoteMode() {
    final currentBoard = state.currentBoard;
    if (currentBoard != null) {
      final newBoard = currentBoard.toggleNoteMode();

      // 선택된 셀의 내용을 selectedCellContent에 저장
      CellContent? selectedCellContent;
      if (newBoard.selectedCell != null) {
        selectedCellContent =
            newBoard.board.getCellContent(newBoard.selectedCell!);
        // 초기값인 경우 selectedCellContent를 null로 설정
        if (selectedCellContent?.isInitial == true) {
          selectedCellContent = null;
        }
      }

      state = state.copyWith(
        currentBoard: newBoard,
        selectedCellContent: selectedCellContent,
      );
    }
  }

  void _handleClearCell() {
    final currentBoard = state.currentBoard;
    final selectedCell = currentBoard?.selectedCell;

    if (currentBoard == null || selectedCell == null) return;

    final currentContent = currentBoard.board.getCellContent(selectedCell);

    // 초기값인 경우 지울 수 없음
    if (currentContent?.isInitial == true) return;

    // 체스 기물이 있는 칸은 지울 수 없음
    if (currentContent?.chessPiece != null) return;

    // 메모 그룹 완료
    _completeMemoGroup();

    // 히스토리에 현재 상태 저장
    _saveToHistory();

    // 체스 기물만 남기고 숫자와 메모 지우기
    if (currentContent?.chessPiece != null) {
      final newContent = CellContent(
        chessPiece: currentContent!.chessPiece,
        isInitial: false,
      );
      final newBoard =
          currentBoard.board.setCellContent(selectedCell, newContent);

      // 셀 지우기 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );
      state = state.copyWith(
        currentBoard: updatedGameBoard,
        selectedCellContent: newContent, // selectedCellContent 업데이트
      );

      // 게임 완료 체크
      _handleCheckGameCompletion();
    } else {
      // 체스 기물도 없으면 완전히 제거
      final newBoard = currentBoard.board.removeCellContent(selectedCell);

      // 셀 지우기 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );
      state = state.copyWith(
        currentBoard: updatedGameBoard,
        selectedCellContent: null, // 셀이 완전히 제거되었으므로 null로 설정
      );

      // 게임 완료 체크
      _handleCheckGameCompletion();
    }
  }

  void _handleCheckErrors() {
    final currentBoard = state.currentBoard;
    if (currentBoard == null) return;

    final errorPositions = <Position>{};

    // 모든 셀을 검사하여 오류 찾기
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final position = Position(row: row, col: col);
        final cellContent = currentBoard.board.getCellContent(position);

        // 사용자가 입력한 숫자가 있는 경우에만 검사
        if (cellContent?.number != null && cellContent?.isInitial == false) {
          final number = cellContent!.number!;

          // 정답과 비교하여 틀린 경우 오류에 추가
          if (!currentBoard.isCorrectAnswer(position, number)) {
            errorPositions.add(position);
          }
        }
      }
    }

    // 오류 셀 업데이트 (히스토리에 저장하지 않음)
    final updatedGameBoard = currentBoard.copyWith(errorCells: errorPositions);
    state = state.copyWith(currentBoard: updatedGameBoard);
  }

  void _handleCheckGameCompletion() {
    final currentBoard = state.currentBoard;
    if (currentBoard == null) return;

    final isCompleted = currentBoard.isCompleted;
    if (isCompleted && !state.isGameCompleted) {
      // 타이머 정지
      _timer?.cancel();
      _timer = null;

      state = state.copyWith(
        isGameCompleted: true,
        showCompletionDialog: true,
        isPaused: true,
      );

      // 게임 완료 시 기록 저장 (비동기 처리)
      _saveGameCompletionRecord().then((_) {
        developer.log('게임 완료 처리 완료', name: 'GameNotifier');
      }).catchError((e) {
        developer.log('게임 완료 처리 실패: $e', name: 'GameNotifier');
      });

      // 게임 완료 시 현재 난이도의 저장된 게임 삭제
      if (_currentDifficulty != null) {
        _gameSaveRepository.clearGameByDifficulty(_currentDifficulty!);
      }
    }
  }

  /// 전체 보드의 빈 칸에 가능한 숫자 후보를 메모로 채우기
  void _handleAutoFillNotes() {
    _recomputeAllNotes();
  }

  // 자동 메모: 전체 보드의 후보 메모 재계산
  void _recomputeAllNotes() {
    final currentBoard = state.currentBoard;
    if (currentBoard == null) return;

    final originalBoard = currentBoard.board;
    final newCells = Map<Position, CellContent>.from(originalBoard.cells);
    bool changed = false;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final p = Position(row: row, col: col);
        final content = newCells[p];

        final hasNumber = content?.number != null;
        final isInitial = content?.isInitial == true;
        final hasPiece = content?.chessPiece != null;

        // 숫자가 있는 칸은 메모 제거
        if (hasNumber) {
          final oldNotes = content?.notes ?? {};
          if (oldNotes.isNotEmpty) {
            newCells[p] = CellContent(
              number: content!.number,
              notes: {},
              chessPiece: content.chessPiece,
              isInitial: content.isInitial,
            );
            changed = true;
          }
          continue;
        }

        // 초기값 또는 체스 기물이 있는 칸은 메모 제거
        if (isInitial || hasPiece) {
          final oldNotes = content?.notes ?? {};
          if (oldNotes.isNotEmpty) {
            newCells[p] = CellContent(
              notes: {},
              chessPiece: content?.chessPiece,
              isInitial: isInitial,
            );
            changed = true;
          }
          continue;
        }

        // 비어있는 일반 칸의 후보 계산 후 메모로 설정
        final candidates = _computeCandidatesForCell(p, originalBoard);
        final oldNotes = content?.notes ?? {};
        final isSame = oldNotes.length == candidates.length &&
            oldNotes.containsAll(candidates);
        if (!isSame) {
          newCells[p] = CellContent(
            number: null,
            notes: candidates,
            chessPiece: content?.chessPiece,
            isInitial: false,
          );
          changed = true;
        }
      }
    }

    if (changed) {
      final updatedBoard = originalBoard.copyWith(cells: newCells);
      final updatedGameBoard = currentBoard.copyWith(board: updatedBoard);
      state = state.copyWith(currentBoard: updatedGameBoard);

      _updateSelectedNumbersFromCurrentCell();
    }
  }

  Set<int> _computeCandidatesForCell(Position position, SudokuBoard board) {
    final candidates = <int>{};
    for (int n = 1; n <= 9; n++) {
      if (board.isValidWithChessConstraints(position: position, number: n)) {
        candidates.add(n);
      }
    }
    return candidates;
  }

  // 체스 기물 제약 범위 하이라이트
  void _handleShowChessConstraint(Position position) {
    final currentBoard = state.currentBoard;
    if (currentBoard == null) return;

    final content = currentBoard.board.getCellContent(position);
    final piece = content?.chessPiece;
    if (piece == null) {
      // 기물이 없으면 일반 셀 선택 동작 수행
      _handleSelectCell(position);
      return;
    }

    final highlighted = _computeConstraintCoverage(position, piece);

    // 선택 셀을 기물 위치로 설정하고 하이라이트 교체
    final newBoard = currentBoard.copyWith(
      selectedCell: position,
      highlightedCells: highlighted,
    );

    state = state.copyWith(currentBoard: newBoard);
  }

  Set<Position> _computeConstraintCoverage(Position origin, ChessPiece piece) {
    switch (piece) {
      case ChessPiece.king:
        return _kingCoverage(origin);
      case ChessPiece.knight:
        return _knightCoverage(origin);
      case ChessPiece.bishop:
        return _bishopCoverage(origin);
      case ChessPiece.rook:
        return _rookCoverage(origin);
      case ChessPiece.queen:
        final s = <Position>{}
          ..addAll(_rookCoverage(origin))
          ..addAll(_bishopCoverage(origin));
        return s;
      case ChessPiece.pawn:
        return <Position>{};
    }
  }

  bool _inBounds(int r, int c) => r >= 0 && r < 9 && c >= 0 && c < 9;

  Set<Position> _kingCoverage(Position o) {
    final res = <Position>{};
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = o.row + dr;
        final c = o.col + dc;
        if (_inBounds(r, c)) res.add(Position(row: r, col: c));
      }
    }
    return res;
  }

  Set<Position> _knightCoverage(Position o) {
    final res = <Position>{};
    const deltas = [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [1, -2],
      [-1, 2],
      [-1, -2],
    ];
    for (final d in deltas) {
      final r = o.row + d[0];
      final c = o.col + d[1];
      if (_inBounds(r, c)) res.add(Position(row: r, col: c));
    }
    return res;
  }

  Set<Position> _bishopCoverage(Position o) {
    final res = <Position>{};
    const dirs = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    for (final d in dirs) {
      var r = o.row + d[0];
      var c = o.col + d[1];
      while (_inBounds(r, c)) {
        res.add(Position(row: r, col: c));
        r += d[0];
        c += d[1];
      }
    }
    return res;
  }

  Set<Position> _rookCoverage(Position o) {
    final res = <Position>{};
    // rows
    for (int c = 0; c < 9; c++) {
      if (c == o.col) continue;
      res.add(Position(row: o.row, col: c));
    }
    // cols
    for (int r = 0; r < 9; r++) {
      if (r == o.row) continue;
      res.add(Position(row: r, col: o.col));
    }
    return res;
  }

  // 게임 완료 기록 저장
  Future<void> _saveGameCompletionRecord() async {
    developer.log('게임 완료 기록 저장 시작', name: 'GameNotifier');

    if (state.currentBoard == null || _currentDifficulty == null) {
      developer.log('게임 완료 기록 저장 실패: 보드 또는 난이도가 null', name: 'GameNotifier');
      return;
    }

    try {
      developer.log('퍼즐 기록 생성 시작', name: 'GameNotifier');
      // 퍼즐 기록 저장
      final record = PuzzleRecord(
        recordId: DateTime.now().millisecondsSinceEpoch.toString(),
        puzzleId: state.currentBoard!.puzzleId,
        difficulty: _currentDifficulty!,
        completedAt: DateTime.now(),
        elapsedSeconds: state.elapsedSeconds,
        hintCount: 0, // TODO: 힌트 사용 횟수 추적 구현
      );

      developer.log('퍼즐 기록 저장 시작: ${record.puzzleId}', name: 'GameNotifier');
      await _puzzleRecordRepository.savePuzzleRecord(record);
      developer.log('퍼즐 기록 저장 완료', name: 'GameNotifier');

      developer.log('게임 완료 기록 저장 완료', name: 'GameNotifier');
    } catch (e) {
      developer.log('게임 완료 기록 저장 실패: $e', name: 'GameNotifier');
      rethrow;
    }
  }

  void _handleHideCompletionDialog() {
    state = state.copyWith(showCompletionDialog: false);
  }

  void _handleCreateCheckpoint(String checkpointId) {
    final currentBoard = state.currentBoard;
    if (currentBoard == null) return;

    final checkpoint = Checkpoint.create(
      board: currentBoard,
      elapsedSeconds: state.elapsedSeconds,
      history: state.history,
      redoHistory: state.redoHistory,
    );

    final newCheckpoints = Map<String, Checkpoint>.from(state.checkpoints);
    newCheckpoints[checkpointId] = checkpoint;

    state = state.copyWith(checkpoints: newCheckpoints);
  }

  void _handleRestoreCheckpoint(String checkpointId) {
    final checkpoint = state.checkpoints[checkpointId];
    if (checkpoint == null) return;

    // 체크포인트에서 보드와 히스토리만 복원
    // 선택된 셀을 초기화한 보드로 복원
    final boardWithoutSelection = checkpoint.board.selectCell(null);

    state = state.copyWith(
      currentBoard: boardWithoutSelection,
      history: checkpoint.history,
      redoHistory: checkpoint.redoHistory,
      canUndo: checkpoint.history.isNotEmpty,
      canRedo: checkpoint.redoHistory.isNotEmpty,
    );
  }

  void _handleDeleteCheckpoint(String checkpointId) {
    final newCheckpoints = Map<String, Checkpoint>.from(state.checkpoints);
    newCheckpoints.remove(checkpointId);

    state = state.copyWith(checkpoints: newCheckpoints);
  }

  void _handleStartTimer() {
    // 이미 타이머가 실행 중이면 중복 실행 방지
    if (_timer != null) return;

    // 게임이 완료되지 않았을 때만 타이머 시작
    if (!state.isGameCompleted) {
      // 타이머 시작 시 일시정지 상태 해제
      state = state.copyWith(isPaused: false);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      });
    }
  }

  void _handlePauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isPaused: true);
  }

  void _handleResetTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      elapsedSeconds: 0,
      isPaused: true,
    );
  }

  // 메모 그룹 완료
  void _completeMemoGroup() {
    if (_isMemoGroupActive && _lastMemoPosition != null) {
      _saveToHistory();
      _lastMemoPosition = null;
      _isMemoGroupActive = false;
    }
  }

  // 메모 히스토리 묶기 처리
  void _handleMemoHistoryGrouping(Position position) {
    // 다른 위치의 메모이거나 첫 번째 메모인 경우
    if (_lastMemoPosition != position) {
      _completeMemoGroup(); // 기존 메모 그룹 완료
      _lastMemoPosition = position;
      _isMemoGroupActive = true;
      // 첫 번째 메모인 경우 히스토리 저장
      _saveToHistory();
    }
    // 같은 위치의 연속된 메모인 경우 히스토리 저장하지 않음 (그룹 유지)
  }

  // 히스토리에 현재 상태 저장
  void _saveToHistory() {
    final currentBoard = state.currentBoard;
    if (currentBoard != null) {
      // 오류 검사 상태를 제거한 보드를 히스토리에 저장
      final boardWithoutErrors = currentBoard.copyWith(errorCells: {});
      final newHistory = List<GameBoard>.from(state.history)
        ..add(boardWithoutErrors);
      final newRedoHistory = <GameBoard>[]; // 새로운 액션 시 redo 히스토리 초기화

      state = state.copyWith(
        history: newHistory,
        redoHistory: newRedoHistory,
        canUndo: newHistory.isNotEmpty,
        canRedo: false,
      );
    }
  }

  // 되돌리기 처리
  void _handleUndo() {
    if (state.history.isNotEmpty) {
      final newHistory = List<GameBoard>.from(state.history);
      final previousBoard = newHistory.removeLast();
      final newRedoHistory = List<GameBoard>.from(state.redoHistory);

      // 현재 보드를 redo 히스토리에 추가 (오류 검사 상태 제거)
      if (state.currentBoard != null) {
        final currentBoardWithoutErrors =
            state.currentBoard!.copyWith(errorCells: {});
        newRedoHistory.add(currentBoardWithoutErrors);
      }

      // 이전 보드로 복원 (오류 검사 상태 제거)
      final previousBoardWithoutErrors = previousBoard.copyWith(errorCells: {});

      state = state.copyWith(
        currentBoard: previousBoardWithoutErrors,
        history: newHistory,
        redoHistory: newRedoHistory,
        canUndo: newHistory.isNotEmpty,
        canRedo: newRedoHistory.isNotEmpty,
      );

      // 선택된 셀의 상태에 따라 selectedNumbers 업데이트
      _updateSelectedNumbersFromCurrentCell();
    }
  }

  // 선택된 셀의 상태에 따라 selectedCellContent 업데이트
  void _updateSelectedNumbersFromCurrentCell() {
    final currentBoard = state.currentBoard;
    if (currentBoard?.selectedCell != null) {
      final selectedCellContent =
          currentBoard!.board.getCellContent(currentBoard.selectedCell!);
      if (selectedCellContent != null && !selectedCellContent.isInitial) {
        state = state.copyWith(selectedCellContent: selectedCellContent);
      } else {
        state = state.copyWith(selectedCellContent: null);
      }
    }
  }

  // 다시 실행 처리
  void _handleRedo() {
    if (state.redoHistory.isNotEmpty) {
      final newRedoHistory = List<GameBoard>.from(state.redoHistory);
      final nextBoard = newRedoHistory.removeLast();
      final newHistory = List<GameBoard>.from(state.history);

      // 현재 보드를 히스토리에 추가 (오류 검사 상태 제거)
      if (state.currentBoard != null) {
        final currentBoardWithoutErrors =
            state.currentBoard!.copyWith(errorCells: {});
        newHistory.add(currentBoardWithoutErrors);
      }

      // 다음 보드로 복원 (오류 검사 상태 제거)
      final nextBoardWithoutErrors = nextBoard.copyWith(errorCells: {});

      state = state.copyWith(
        currentBoard: nextBoardWithoutErrors,
        history: newHistory,
        redoHistory: newRedoHistory,
        canUndo: newHistory.isNotEmpty,
        canRedo: newRedoHistory.isNotEmpty,
      );

      // 선택된 셀의 상태에 따라 selectedNumbers 업데이트
      _updateSelectedNumbersFromCurrentCell();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 갈 때 타이머 상태 저장 후 일시정지
        _wasTimerRunningBeforePause = !this.state.isPaused;
        if (!this.state.isPaused) {
          _handlePauseTimer();
        }
        // 자동 저장
        autoSave();
        break;
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아올 때 이전에 실행 중이었다면 재시작
        if (_wasTimerRunningBeforePause && !this.state.isGameCompleted) {
          _handleStartTimer();
        }
        break;
      case AppLifecycleState.detached:
        // 앱 종료 시 자동 저장
        autoSave();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

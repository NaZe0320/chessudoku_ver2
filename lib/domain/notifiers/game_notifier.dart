import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/checkpoint.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class GameNotifier extends BaseNotifier<GameIntent, GameState>
    with WidgetsBindingObserver {
  Timer? _timer;
  final GameSaveRepository _gameSaveRepository;
  bool _wasTimerRunningBeforePause = false; // 앱이 백그라운드로 가기 전 타이머 상태
  Difficulty? _currentDifficulty; // 현재 게임 난이도

  // 메모 히스토리 묶기 관련 변수들
  Position? _lastMemoPosition; // 마지막 메모 입력 위치
  bool _isMemoGroupActive = false; // 메모 그룹 활성화 상태

  GameNotifier(this._gameSaveRepository) : super(const GameState()) {
    // 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  /// 게임 상태 자동 저장
  Future<void> autoSave() async {
    developer.log('자동 저장 시작', name: 'GameNotifier');
    if (state.currentBoard != null && _currentDifficulty != null) {
      developer.log('저장 조건 충족 - 보드 존재, 난이도: $_currentDifficulty',
          name: 'GameNotifier');
      final success =
          await _gameSaveRepository.saveCurrentGame(state, _currentDifficulty!);
      developer.log('자동 저장 결과: $success', name: 'GameNotifier');
    } else {
      developer.log(
          '저장 조건 불충족 - 보드: ${state.currentBoard != null}, 난이도: $_currentDifficulty',
          name: 'GameNotifier');
    }
  }

  /// 게임 초기화 (MainNotifier에서 호출)
  void initializeGame(GameBoard gameBoard, {Difficulty? difficulty}) {
    developer.log('게임 초기화 시작 - 난이도: $difficulty', name: 'GameNotifier');
    _currentDifficulty = difficulty;

    // 선택된 셀을 초기화한 보드 생성
    final boardWithoutSelection = gameBoard.selectCell(null);

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
    developer.log('게임 초기화 완료', name: 'GameNotifier');
  }

  /// 저장된 게임 로드 (MainNotifier에서 호출)
  void loadSavedGame() {
    developer.log('저장된 게임 로드 시작', name: 'GameNotifier');
    final savedGameData = _gameSaveRepository.loadCurrentGame();
    if (savedGameData != null) {
      developer.log('저장된 게임 데이터 로드 성공', name: 'GameNotifier');
      developer.log('로드된 보드 셀 수: ${savedGameData.board.board.cells.length}',
          name: 'GameNotifier');
      developer.log('로드된 보드 선택된 셀: ${savedGameData.board.selectedCell}',
          name: 'GameNotifier');
      _currentDifficulty = savedGameData.difficulty;

      // 선택된 셀을 초기화한 보드 생성
      final boardWithoutSelection = savedGameData.board.selectCell(null);

      state = state.copyWith(
        currentBoard: boardWithoutSelection,
        history: savedGameData.history,
        redoHistory: savedGameData.redoHistory,
        elapsedSeconds: savedGameData.elapsedSeconds,
        canUndo: savedGameData.history.isNotEmpty,
        canRedo: savedGameData.redoHistory.isNotEmpty,
        isPaused: false,
        isGameCompleted: false,
        showCompletionDialog: false,
        checkpoints: savedGameData.checkpoints, // 저장된 체크포인트 복원
        selectedCellContent: null, // 선택된 셀 내용 초기화
      );

      developer.log(
          '상태 업데이트 완료 - 현재 보드 셀 수: ${state.currentBoard?.board.cells.length}',
          name: 'GameNotifier');

      // 타이머 시작
      _handleStartTimer();
      developer.log('저장된 게임 로드 완료 - 경과시간: ${savedGameData.elapsedSeconds}초',
          name: 'GameNotifier');
    } else {
      developer.log('저장된 게임 데이터가 없습니다.', name: 'GameNotifier');
    }
  }

  @override
  void onIntent(GameIntent intent) {
    switch (intent) {
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
        newNotes.add(number); // 없으면 추가
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
      // 기존 메모 토글
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

      final newBoard = currentBoard.board.setCellContent(position, newContent);

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

      // 게임 완료 시 저장된 게임 삭제
      _gameSaveRepository.clearCurrentGame();
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

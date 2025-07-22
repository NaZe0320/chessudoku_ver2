import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/checkpoint.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';

class GameNotifier extends BaseNotifier<GameIntent, GameState>
    with WidgetsBindingObserver {
  Timer? _timer;
  final GameSaveRepository _gameSaveRepository;
  bool _wasTimerRunningBeforePause = false; // 앱이 백그라운드로 가기 전 타이머 상태

  GameNotifier(this._gameSaveRepository) : super(const GameState()) {
    // 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  /// 게임 상태 자동 저장
  Future<void> autoSave() async {
    try {
      await _gameSaveRepository.saveCurrentGame(state);
    } catch (e) {
      print('자동 저장 실패: $e');
    }
  }

  /// 저장된 게임 로드
  Future<void> loadSavedGame() async {
    try {
      final savedState = _gameSaveRepository.loadCurrentGame();
      if (savedState != null) {
        state = savedState;

        // 로드된 게임이 완료되지 않았고 타이머가 실행 중이었다면 타이머 재시작
        if (!savedState.isGameCompleted && savedState.isTimerRunning) {
          _handleStartTimer();
        }
      }
    } catch (e) {
      print('게임 로드 실패: $e');
    }
  }

  /// 저장된 게임 삭제
  Future<void> clearSavedGame() async {
    try {
      await _gameSaveRepository.clearCurrentGame();
    } catch (e) {
      print('게임 삭제 실패: $e');
    }
  }

  @override
  void onIntent(GameIntent intent) {
    switch (intent) {
      case SelectNumberIntent():
        _handleSelectNumber(intent.number);
      case ClearSelectionIntent():
        _handleClearSelection();
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
      case InitializeTestBoardIntent():
        _handleInitializeTestBoard();
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

  void _handleSelectNumber(int number) {
    final newSelected = Set<int>.from(state.selectedNumbers);
    if (newSelected.contains(number)) {
      newSelected.remove(number);
    } else {
      newSelected.add(number);
    }
    state = state.copyWith(selectedNumbers: newSelected);
  }

  void _handleClearSelection() {
    state = state.copyWith(selectedNumbers: {});
  }

  void _handleSelectCell(position) {
    final currentBoard = state.currentBoard;
    if (currentBoard != null) {
      final newBoard = currentBoard.selectCell(position);
      state = state.copyWith(currentBoard: newBoard);
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
      // 일반 모드인 경우 숫자 입력
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

    // 숫자가 이미 입력된 경우 메모 불가
    if (currentContent?.number != null) return;

    final newContent =
        currentContent?.toggleNote(number) ?? CellContent(notes: {number});

    final newBoard = currentBoard.board.setCellContent(position, newContent);

    // 메모 입력 시 모든 오류 검사 내용 초기화
    final updatedGameBoard = currentBoard.copyWith(
      board: newBoard,
      errorCells: {}, // 오류 검사 내용 초기화
    );

    state = state.copyWith(currentBoard: updatedGameBoard);
  }

  void _inputNumberToCell(Position position, int number) {
    final currentBoard = state.currentBoard!;
    final currentContent = currentBoard.board.getCellContent(position);

    // 초기값인 경우 수정 불가
    if (currentContent?.isInitial == true) return;

    // 히스토리에 현재 상태 저장
    _saveToHistory();

    // 새로운 셀 내용 생성 (메모는 지우고 숫자만)
    final newContent = CellContent(
      number: number,
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

    // 게임 완료 체크
    _handleCheckGameCompletion();
  }

  void _handleToggleNoteMode() {
    final currentBoard = state.currentBoard;
    if (currentBoard != null) {
      final newBoard = currentBoard.toggleNoteMode();
      state = state.copyWith(currentBoard: newBoard);
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
      state = state.copyWith(currentBoard: updatedGameBoard);

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
      state = state.copyWith(currentBoard: updatedGameBoard);

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
        isTimerRunning: false,
      );

      // 게임 완료 시 자동 저장
      autoSave();
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

    // 체크포인트에서 보드와 히스토리 복원 (시간은 복원하지 않음)
    state = state.copyWith(
      currentBoard: checkpoint.board,
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

  void _handleInitializeTestBoard() {
    // 완성된 스도쿠 답안 (체스 기물 위치는 빈 칸으로)
    final solutionPuzzle = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, null, 2, 1, 9, 5, 3, 4, 8], // (1,1) knight 위치
      [1, 9, 8, 3, null, 2, 5, 6, 7], // (2,4) bishop 위치
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, null, 3, 7, 9, 1], // (4,4) queen 위치
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, null, 7, 2, 8, 4], // (6,4) rook 위치
      [2, 8, 7, 4, 1, 9, 6, 3, 5], // (7,2) pawn 위치
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];

    // 빈칸이 있는 퍼즐 (일부 셀을 null로 설정)
    final puzzleWithBlanks = [
      [5, 3, null, 6, 7, 8, 9, null, 2],
      [6, null, 2, 1, 9, null, 3, 4, 8], // (1,1) knight 위치
      [null, 9, 8, 3, null, 2, 5, 6, null], // (2,4) bishop 위치
      [8, 5, null, 7, 6, 1, null, 2, 3],
      [4, null, 6, 8, null, 3, 7, null, 1], // (4,4) queen 위치
      [7, 1, null, 9, 2, null, 8, 5, 6],
      [null, 6, 1, 5, null, 7, 2, 8, null], // (6,4) rook 위치
      [2, 8, null, 4, 1, null, 6, 3, 5], // (7,2) pawn 위치
      [3, null, 5, 2, 8, 6, null, 7, 9],
    ];

    // 체스 기물 배치 (일부 셀에만)
    final chessPieces = <Position, ChessPiece>{
      const Position(row: 1, col: 1): ChessPiece.knight,
      const Position(row: 2, col: 4): ChessPiece.bishop,
      const Position(row: 4, col: 4): ChessPiece.queen,
      const Position(row: 6, col: 4): ChessPiece.rook,
      const Position(row: 7, col: 2): ChessPiece.pawn,
    };

    // 체스 기물을 포함한 보드 생성
    final puzzleBoard = SudokuBoard.fromPuzzleWithChess(
      puzzle: puzzleWithBlanks,
      chessPieces: chessPieces,
    );

    final solutionBoard = SudokuBoard.fromPuzzle(solutionPuzzle);

    final gameBoard = GameBoard(
      board: puzzleBoard,
      solutionBoard: solutionBoard,
      difficulty: Difficulty.medium,
      puzzleId: 'test_puzzle_with_chess',
    );

    state = state.copyWith(
      currentBoard: gameBoard,
      history: [],
      redoHistory: [],
      canUndo: false,
      canRedo: false,
    );
  }

  void _handleStartTimer() {
    if (!state.isTimerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      });
      state = state.copyWith(isTimerRunning: true);
    }
  }

  void _handlePauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isTimerRunning: false);
  }

  void _handleResetTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      elapsedSeconds: 0,
      isTimerRunning: false,
    );
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
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 갈 때 타이머 상태 저장 후 일시정지
        _wasTimerRunningBeforePause = this.state.isTimerRunning;
        if (this.state.isTimerRunning) {
          _handlePauseTimer();
        }
        autoSave();
        break;
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아올 때 이전에 실행 중이었다면 재시작
        if (_wasTimerRunningBeforePause && !this.state.isGameCompleted) {
          _handleStartTimer();
        }
        break;
      case AppLifecycleState.detached:
        // 앱이 완전히 종료될 때 자동 저장
        autoSave();
        break;
      default:
        break;
    }
  }
}

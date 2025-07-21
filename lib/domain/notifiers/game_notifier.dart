import 'dart:async';
import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

class GameNotifier extends BaseNotifier<GameIntent, GameState> {
  Timer? _timer;

  GameNotifier() : super(const GameState());

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
      case InitializeTestBoardIntent():
        _handleInitializeTestBoard();
      case StartTimerIntent():
        _handleStartTimer();
      case PauseTimerIntent():
        _handlePauseTimer();
      case ResetTimerIntent():
        _handleResetTimer();
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
    } else {
      // 체스 기물도 없으면 완전히 제거
      final newBoard = currentBoard.board.removeCellContent(selectedCell);

      // 셀 지우기 시 모든 오류 검사 내용 초기화
      final updatedGameBoard = currentBoard.copyWith(
        board: newBoard,
        errorCells: {}, // 오류 검사 내용 초기화
      );
      state = state.copyWith(currentBoard: updatedGameBoard);
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

    // 오류 셀 업데이트
    final updatedGameBoard = currentBoard.copyWith(errorCells: errorPositions);
    state = state.copyWith(currentBoard: updatedGameBoard);
  }

  void _handleInitializeTestBoard() {
    // 완성된 스도쿠 답안
    final solutionPuzzle = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];

    // 빈칸이 있는 퍼즐 (일부 셀을 null로 설정)
    final puzzleWithBlanks = [
      [5, 3, null, 6, 7, 8, 9, null, 2],
      [6, null, 2, 1, 9, null, 3, 4, 8],
      [null, 9, 8, 3, null, 2, 5, 6, null],
      [8, 5, null, 7, 6, 1, null, 2, 3],
      [4, null, 6, 8, null, 3, 7, null, 1],
      [7, 1, null, 9, 2, null, 8, 5, 6],
      [null, 6, 1, 5, null, 7, 2, 8, null],
      [2, 8, null, 4, 1, null, 6, 3, 5],
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

    state = state.copyWith(currentBoard: gameBoard);
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

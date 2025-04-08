import 'dart:async';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  PuzzleNotifier() : super(const PuzzleState());

  Timer? _timer;

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  // 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  // 타이머 시작
  void startTimer() {
    if (state.isTimerRunning || _timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        isTimerRunning: true,
      );
    });

    // 타이머 상태를 즉시 실행 중으로 설정
    state = state.copyWith(isTimerRunning: true);
  }

  // 타이머 정지
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isTimerRunning: false);
  }

  // 타이머 초기화 및 재시작
  void resetTimer() {
    stopTimer();
    state = state.copyWith(elapsedTime: Duration.zero);
    startTimer();
  }

  // 타이머 일시정지
  void pauseTimer() {
    if (state.isTimerRunning) {
      _timer?.cancel();
      _timer = null;
      state = state.copyWith(isTimerRunning: false);
    }
  }

  // 타이머 재개
  void resumeTimer() {
    if (!state.isTimerRunning && !state.isCompleted) {
      startTimer();
    }
  }

  // 새 게임 초기화 (보드 데이터 주입)
  void initializeGameWithBoard({
    required List<List<CellContent>> gameBoard,
    required int boardSize,
  }) {
    state = state.copyWith(
      board: gameBoard,
      selectedRow: null,
      selectedCol: null,
      isCompleted: false,
      boardSize: boardSize,
      elapsedTime: Duration.zero,
      history: [], // 히스토리 초기화
      historyIndex: -1, // 히스토리 인덱스 초기화
      isNoteMode: false, // 메모 모드 비활성화
    );
  }

  // 저장된 게임 상태로 초기화
  void initializeGameWithState(PuzzleState savedState) {
    // 저장된 상태를 그대로 사용하되, 타이머는 정지 상태로 시작
    state = savedState.copyWith(isTimerRunning: false);
  }

  // 셀 선택
  void selectCell(int row, int col) {
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  // 보드 업데이트
  void updateBoard(List<List<CellContent>> newBoard, bool isCompleted) {
    state = state.copyWith(
      board: newBoard,
      isCompleted: isCompleted,
    );
  }

  // 히스토리와 함께 보드 업데이트
  void updateBoardWithState(
    List<List<CellContent>> newBoard,
    PuzzleState newState, {
    bool isCompleted = false,
  }) {
    state = newState.copyWith(
      board: newBoard,
      isCompleted: isCompleted,
      // 숫자 입력시 오류 셀 초기화
      errorCells: {},
    );
  }

  // 상태 업데이트
  void updateState(PuzzleState newState) {
    state = newState.copyWith(
      // 상태 변경시 오류 셀 초기화
      errorCells: {},
    );
  }

  // 메모 모드 토글
  void toggleNoteMode() {
    state = state.toggleNoteMode();
  }

  // 게임 재시작
  void restartGame(List<List<CellContent>> newBoard) {
    state = state.copyWith(
      board: newBoard,
      selectedRow: null,
      selectedCol: null,
      isCompleted: false,
      history: [], // 히스토리 초기화
      historyIndex: -1, // 히스토리 인덱스 초기화
      isNoteMode: false, // 메모 모드 비활성화
    );

    resetTimer();
  }

  int checkErrors() {
    // 오류 셀을 업데이트
    final errorCount = updateErrorCells();
    return errorCount;
  }

  int updateErrorCells() {
    final currentState = state;
    final board = currentState.board;
    final boardSize = currentState.boardSize;

    // 오류가 있는 셀을 저장할 Set
    final Set<String> errorCells = {};

    // 오류가 있는 셀 식별
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final cell = board[row][col];

        // 사용자가 입력한 숫자인 경우만 체크 (초기값이 아니고 숫자가 있는 경우)
        if (!cell.isInitial && cell.hasNumber) {
          // 오류 체크를 위해 임시 보드 생성
          final tmpBoard = List.generate(
            boardSize,
            (r) => List.generate(
              boardSize,
              (c) => board[r][c].number,
            ),
          );

          final chessPieces = board;

          // 현재 셀에 대한 유효성 검증
          if (!_isValidMove(tmpBoard, chessPieces, row, col)) {
            errorCells.add('$row,$col');
          }
        }
      }
    }

    // 상태 업데이트
    state = currentState.copyWith(
      errorCells: errorCells,
    );

    return errorCells.length;
  }

  // 오류 검사를 위한 보조 메서드
  bool _isValidMove(List<List<int?>> board, List<List<CellContent>> chessPieces,
      int row, int col) {
    final number = board[row][col];
    if (number == null) return true; // 비어있는 셀은 항상 유효

    // 1. 기본 스도쿠 규칙 검증
    if (!_isValidSudokuPlacement(board, row, col)) {
      return false;
    }

    // 2. 체스 기물 규칙 검증
    if (!_isValidChessPiecePlacement(board, chessPieces, row, col)) {
      return false;
    }

    return true;
  }

  // 스도쿠 규칙 검증
  bool _isValidSudokuPlacement(List<List<int?>> board, int row, int col) {
    final number = board[row][col];
    if (number == null) return true;

    // 행 검증
    for (int c = 0; c < board.length; c++) {
      if (c != col && board[row][c] == number) {
        return false;
      }
    }

    // 열 검증
    for (int r = 0; r < board.length; r++) {
      if (r != row && board[r][col] == number) {
        return false;
      }
    }

    // 3x3 박스 검증
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r != row && c != col && board[r][c] == number) {
          return false;
        }
      }
    }

    return true;
  }

  // 체스 기물 규칙 검증
  bool _isValidChessPiecePlacement(List<List<int?>> board,
      List<List<CellContent>> chessPieces, int row, int col) {
    final number = board[row][col];
    if (number == null) return true;

    // 체스 기물 규칙 검증
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board.length; c++) {
        // 기물이 없거나 같은 셀이면 건너뜀
        if (!chessPieces[r][c].hasChessPiece || (r == row && c == col)) {
          continue;
        }

        // 기물에 따른 이동 검증
        final chessPiece = chessPieces[r][c].chessPiece!;

        // 기물의 특성에 따라 해당 위치에서 이동 가능한 모든 셀 검사
        if (_canPieceAttack(chessPiece, r, c, row, col)) {
          // 공격 가능한 위치에 같은 숫자가 있는지 확인
          if (board[r][c] == number) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // 체스 기물이 특정 위치를 공격할 수 있는지 확인
  bool _canPieceAttack(ChessPiece piece, int pieceRow, int pieceCol,
      int targetRow, int targetCol) {
    switch (piece) {
      case ChessPiece.knight:
        // 나이트의 L자 이동
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

      case ChessPiece.rook:
        // 룩의 수직/수평 이동
        return pieceRow == targetRow || pieceCol == targetCol;

      case ChessPiece.bishop:
        // 비숍의 대각선 이동
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return rowDiff == colDiff;

      case ChessPiece.queen:
        // 퀸의 모든 방향 이동 (룩 + 비숍)
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return pieceRow == targetRow ||
            pieceCol == targetCol ||
            rowDiff == colDiff;

      case ChessPiece.king:
        // 킹의 한 칸 이동 (모든 방향)
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return rowDiff <= 1 && colDiff <= 1;
    }
  }
}

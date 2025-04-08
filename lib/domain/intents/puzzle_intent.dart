import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/repositories/puzzle_repository.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/notifiers/puzzle_notifier.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class PuzzleIntent {
  final Ref ref;

  PuzzleIntent(this.ref);

  // 노티파이어에 대한 참조를 쉽게 얻기 위한 getter
  PuzzleNotifier get _notifier => ref.read(puzzleNotifierProvider.notifier);

  // 레포지토리에 대한 참조를 쉽게 얻기 위한 getter
  PuzzleRepository get _repository => ref.read(puzzleRepositoryProvider);

  // 체스도쿠 생성기에 대한 참조
  ChessSudokuGenerator get _generator => ref.read(chessSudokuGeneratorProvider);

  // 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    _notifier.changeDifficulty(difficulty);
  }

  // 새 게임 초기화
  Future<void> initializeGame() async {
    // 타이머 중지
    _notifier.stopTimer();

    final state = ref.read(puzzleProvider);
    final difficulty = state.difficulty;

    // 저장된 게임 상태가 있는지 확인
    final hasSavedState = _repository.hasCachedPuzzleState(difficulty);

    if (hasSavedState) {
      // 저장된 게임 상태 불러오기
      final savedState = await _repository.loadPuzzleState(difficulty);
      if (savedState != null) {
        // 저장된 상태로 초기화
        _notifier.initializeGameWithState(savedState);
        // 타이머 시작
        _notifier.startTimer();
        return;
      }
    }

    // 저장된 상태가 없는 경우 새 게임 생성
    const boardSize = ChessSudokuGenerator.boardSize;

    // 체스도쿠 생성기를 사용하여 보드 생성
    final gameBoard = await _generator.generatePuzzle(difficulty);

    // 상태 업데이트
    _notifier.initializeGameWithBoard(
        gameBoard: gameBoard, boardSize: boardSize);

    // 타이머 시작
    _notifier.startTimer();
  }

  // 현재 게임 상태를 캐시에 저장
  Future<bool> saveGameState() async {
    final currentState = ref.read(puzzleProvider);
    return await _repository.savePuzzleState(currentState);
  }

  // 캐시에서 게임 상태 삭제
  Future<bool> clearSavedGameState([Difficulty? difficulty]) async {
    if (difficulty != null) {
      return await _repository.clearPuzzleState(difficulty);
    } else {
      final currentState = ref.read(puzzleProvider);
      return await _repository.clearPuzzleState(currentState.difficulty);
    }
  }

  // 저장된 게임이 있는지 확인
  bool hasSavedGame(Difficulty difficulty) {
    return _repository.hasCachedPuzzleState(difficulty);
  }

  // 셀 선택
  void selectCell(int row, int col) {
    final state = ref.read(puzzleProvider);
    if (row < 0 ||
        row >= state.boardSize ||
        col < 0 ||
        col >= state.boardSize) {
      return;
    }
    _notifier.selectCell(row, col);
  }

  // 선택된 셀에 숫자 입력
  void enterNumber(int number) {
    final state = ref.read(puzzleProvider);
    if (state.selectedRow == null ||
        state.selectedCol == null ||
        state.isSelectedCellInitial ||
        state.board[state.selectedRow!][state.selectedCol!].hasChessPiece) {
      return;
    }

    if (number < 1 || number > state.boardSize) {
      return;
    }

    final row = state.selectedRow!;
    final col = state.selectedCol!;
    final oldContent = state.board[row][col];

    // 메모 모드인 경우
    if (state.isNoteMode) {
      final CellContent newContent = oldContent.toggleNote(number);

      // 액션 생성 및 히스토리에 추가
      final action = PuzzleAction(
        row: row,
        col: col,
        oldContent: oldContent,
        newContent: newContent,
      );

      final newState = state.addAction(action);

      // 보드 업데이트
      final newBoard = _deepCopyBoard(state.board);
      newBoard[row][col] = newContent;

      _notifier.updateBoardWithState(newBoard, newState);
    } else {
      // 일반 모드 - 숫자 입력 또는 제거
      // 이미 같은 숫자가 있는 경우 숫자 제거
      if (oldContent.hasNumber && oldContent.number == number) {
        const CellContent newContent = CellContent();

        // 액션 생성 및 히스토리에 추가
        final action = PuzzleAction(
          row: row,
          col: col,
          oldContent: oldContent,
          newContent: newContent,
        );

        final newState = state.addAction(action);

        // 보드 업데이트
        final newBoard = _deepCopyBoard(state.board);
        newBoard[row][col] = newContent;

        _notifier.updateBoardWithState(newBoard, newState, isCompleted: false);
      } else {
        // 다른 숫자를 입력하는 경우
        final CellContent newContent = CellContent(number: number);

        // 액션 생성 및 히스토리에 추가
        final action = PuzzleAction(
          row: row,
          col: col,
          oldContent: oldContent,
          newContent: newContent,
        );

        final newState = state.addAction(action);

        // 보드 업데이트
        final newBoard = _deepCopyBoard(state.board);
        newBoard[row][col] = newContent;

        final isCompleted = _checkCompletion(newBoard);

        _notifier.updateBoardWithState(newBoard, newState,
            isCompleted: isCompleted);

        if (isCompleted) {
          _notifier.stopTimer();
          // 게임 완료 시 저장된 상태 삭제
          clearSavedGameState();
        }
      }
    }
  }

  // 선택된 셀 값 삭제
  void clearValue() {
    final state = ref.read(puzzleProvider);
    if (state.selectedRow == null ||
        state.selectedCol == null ||
        state.isSelectedCellInitial ||
        state.board[state.selectedRow!][state.selectedCol!].hasChessPiece) {
      return;
    }

    final row = state.selectedRow!;
    final col = state.selectedCol!;
    final oldContent = state.board[row][col];
    const CellContent newContent = CellContent();

    // 액션 생성 및 히스토리에 추가
    final action = PuzzleAction(
      row: row,
      col: col,
      oldContent: oldContent,
      newContent: newContent,
    );

    final newState = state.addAction(action);

    // 보드 업데이트
    final newBoard = _deepCopyBoard(state.board);
    newBoard[row][col] = newContent;

    _notifier.updateBoardWithState(newBoard, newState, isCompleted: false);
  }

  // 메모 모드 토글
  void toggleNoteMode() {
    _notifier.toggleNoteMode();
  }

  // 오류 검사 모드 토글
  void checkErrors() {
    _notifier.checkErrors();
  }

  // 되돌리기 액션
  void undoAction() {
    final state = ref.read(puzzleProvider);
    if (!state.canUndo) return;

    final newState = state.undo();
    _notifier.updateState(newState);
  }

  // 다시 실행 액션
  void redoAction() {
    final state = ref.read(puzzleProvider);
    if (!state.canRedo) return;

    final newState = state.redo();
    _notifier.updateState(newState);

    // 완료 여부 확인 후 처리
    if (_checkCompletion(newState.board)) {
      _notifier.stopTimer();
      clearSavedGameState();
    }
  }

  // 보드의 깊은 복사 생성
  List<List<CellContent>> _deepCopyBoard(List<List<CellContent>> board) {
    return List.generate(
      board.length,
      (row) => List.generate(
        board[row].length,
        (col) => board[row][col].copyWith(),
      ),
    );
  }

  // 퍼즐 완료 여부 확인
  bool _checkCompletion(List<List<CellContent>> board) {
    return ChessSudokuValidator.isValidBoard(board);
  }

  // 체스 기물을 문자로 변환 (UI 표시용)
  String getChessPieceSymbol(ChessPiece piece) {
    switch (piece) {
      case ChessPiece.king:
        return '♚';
      case ChessPiece.queen:
        return '♛';
      case ChessPiece.rook:
        return '♜';
      case ChessPiece.bishop:
        return '♝';
      case ChessPiece.knight:
        return '♞';
    }
  }

  // 타이머 일시정지
  void pauseTimer() {
    _notifier.pauseTimer();
  }

  // 타이머 재개
  void resumeTimer() {
    _notifier.resumeTimer();
  }

  // 메모 자동 채우기
  void fillNotes() {
    final state = ref.read(puzzleProvider);
    final boardSize = state.boardSize;
    final board = state.board;

    // 보드의 깊은 복사 생성
    final newBoard = _deepCopyBoard(board);

    // 히스토리에 추가할 액션 목록
    List<PuzzleAction> actions = [];

    // 각 빈 셀에 대해 가능한 후보 숫자 계산
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        // 이미 숫자가 있거나 체스 기물이 있거나 초기 셀이면 건너뛰기
        if (board[row][col].hasNumber ||
            board[row][col].hasChessPiece ||
            board[row][col].isInitial) {
          continue;
        }

        // 현재 셀에 대한 가능한 후보 숫자 구하기
        Set<int> possibleNumbers = _getPossibleNumbers(board, row, col);

        // 기존 메모와 비교하여 액션 생성
        final oldContent = board[row][col];
        final newContent = CellContent(notes: possibleNumbers);

        if (oldContent.notes != possibleNumbers) {
          // 액션 생성
          final action = PuzzleAction(
            row: row,
            col: col,
            oldContent: oldContent,
            newContent: newContent,
          );

          actions.add(action);

          // 보드 업데이트
          newBoard[row][col] = newContent;
        }
      }
    }

    // 액션이 없으면 종료
    if (actions.isEmpty) {
      return;
    }

    // 액션들을 히스토리에 추가하여 새로운 상태 생성
    PuzzleState newState = state;
    for (final action in actions) {
      newState = newState.addAction(action);
    }

    // 상태 업데이트
    _notifier.updateBoard(newBoard, false);
  }

  // 특정 셀의 가능한 후보 숫자 계산
  Set<int> _getPossibleNumbers(
      List<List<CellContent>> board, int row, int col) {
    final boardSize = board.length;
    Set<int> allNumbers = Set.from(List.generate(boardSize, (i) => i + 1));
    Set<int> usedNumbers = {};

    // 같은 행에 있는 숫자 제외
    for (int c = 0; c < boardSize; c++) {
      if (board[row][c].hasNumber) {
        usedNumbers.add(board[row][c].number!);
      }
    }

    // 같은 열에 있는 숫자 제외
    for (int r = 0; r < boardSize; r++) {
      if (board[r][col].hasNumber) {
        usedNumbers.add(board[r][col].number!);
      }
    }

    // 같은 3x3 박스에 있는 숫자 제외
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c].hasNumber) {
          usedNumbers.add(board[r][c].number!);
        }
      }
    }

    // 체스 기물 규칙에 의해 제외되는 숫자
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        // 체스 기물이 없으면 건너뛰기
        if (!board[r][c].hasChessPiece) continue;

        // 현재 셀이 기물의 공격 범위에 있는지 확인
        if (_canPieceAttack(board[r][c].chessPiece!, r, c, row, col)) {
          // 공격 범위에 있는 경우 해당 기물과 같은 숫자가 있는 다른 셀 찾기
          for (int r2 = 0; r2 < boardSize; r2++) {
            for (int c2 = 0; c2 < boardSize; c2++) {
              // 자기 자신이거나 체스 기물이 있는 셀이면 건너뛰기
              if ((r2 == row && c2 == col) || board[r2][c2].hasChessPiece)
                continue;

              // 숫자가 없으면 건너뛰기
              if (!board[r2][c2].hasNumber) continue;

              // 체스 기물이 두 셀을 모두 공격할 수 있는지 확인
              if (_canPieceAttack(board[r][c].chessPiece!, r, c, r2, c2)) {
                // 이 숫자는 현재 셀에 놓을 수 없음
                usedNumbers.add(board[r2][c2].number!);
              }
            }
          }
        }
      }
    }

    // 사용 가능한 숫자 계산
    allNumbers.removeAll(usedNumbers);
    return allNumbers;
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

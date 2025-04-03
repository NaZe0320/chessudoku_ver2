import 'dart:math';

import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/notifiers/puzzle_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleIntent {
  final Ref ref;

  PuzzleIntent(this.ref);

  // 노티파이어에 대한 참조를 쉽게 얻기 위한 getter
  PuzzleNotifier get _notifier => ref.read(puzzleNotifierProvider.notifier);

  // 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    _notifier.changeDifficulty(difficulty);
  }

  // 새 게임 초기화 (간소화된 버전)
  void initializeGame() {
    // 타이머 중지
    _notifier.stopTimer();

    const boardSize = 9;
    final random = Random();

    // 간소화된 방식으로 보드 생성 (랜덤 숫자와 체스 기물)
    final gameBoard = List.generate(
      boardSize,
      (row) => List.generate(
        boardSize,
        (col) {
          // 랜덤하게 셀 내용 결정 (80%는 숫자, 20%는 체스 기물)
          if (random.nextDouble() < 0.2) {
            // 체스 기물 (랜덤 선택)
            final pieceIndex = random.nextInt(ChessPiece.values.length);
            return CellContent(
              chessPiece: ChessPiece.values[pieceIndex],
              isInitial: true,
            );
          } else {
            // 숫자 (50% 확률로 초기값 또는 빈칸)
            if (random.nextBool()) {
              return CellContent(
                number: random.nextInt(9) + 1,
                isInitial: true,
              );
            } else {
              return const CellContent();
            }
          }
        },
      ),
    );

    // 상태 업데이트
    _notifier.initializeGameWithBoard(
        gameBoard: gameBoard, boardSize: boardSize);

    // 타이머 시작
    _notifier.startTimer();
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

    final newBoard = _deepCopyBoard(state.board);
    newBoard[state.selectedRow!][state.selectedCol!] =
        CellContent(number: number);

    final isCompleted = _checkCompletion(newBoard);

    _notifier.updateBoard(newBoard, isCompleted);

    if (isCompleted) {
      _notifier.stopTimer();
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

    final newBoard = _deepCopyBoard(state.board);
    newBoard[state.selectedRow!][state.selectedCol!] = const CellContent();

    _notifier.updateBoard(newBoard, false);
  }

  // 게임 재시작
  void restartGame() {
    final state = ref.read(puzzleProvider);
    // 원래 보드의 초기값만 유지하고 나머지 셀은 비우기
    final boardSize = state.boardSize;
    final newBoard = List.generate(
      boardSize,
      (row) => List.generate(
        boardSize,
        (col) => state.board[row][col].isInitial
            ? state.board[row][col]
            : const CellContent(),
      ),
    );

    _notifier.restartGame(newBoard);
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
    final size = board.length;

    // 모든 빈 셀 확인 (체스 기물이 없는 셀에 숫자가 있어야 함)
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (!board[row][col].hasChessPiece && !board[row][col].hasNumber) {
          return false;
        }
      }
    }

    // 각 행에 1-9 숫자가 하나씩만 있는지 확인
    for (int row = 0; row < size; row++) {
      final numbers = <int>{};
      for (int col = 0; col < size; col++) {
        final cell = board[row][col];
        if (cell.hasNumber) {
          if (numbers.contains(cell.number)) {
            return false;
          }
          numbers.add(cell.number!);
        }
      }
    }

    // 각 열에 1-9 숫자가 하나씩만 있는지 확인
    for (int col = 0; col < size; col++) {
      final numbers = <int>{};
      for (int row = 0; row < size; row++) {
        final cell = board[row][col];
        if (cell.hasNumber) {
          if (numbers.contains(cell.number)) {
            return false;
          }
          numbers.add(cell.number!);
        }
      }
    }

    // 각 3x3 박스에 1-9 숫자가 하나씩만 있는지 확인
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final numbers = <int>{};
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            final cell = board[boxRow * 3 + row][boxCol * 3 + col];
            if (cell.hasNumber) {
              if (numbers.contains(cell.number)) {
                return false;
              }
              numbers.add(cell.number!);
            }
          }
        }
      }
    }

    // 모든 검사 통과하면 완료
    return true;
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
}

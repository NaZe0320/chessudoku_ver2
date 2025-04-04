import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

/// 체스도쿠 규칙 검증기
///
/// 체스도쿠 규칙에 맞게 셀 유효성을 검사합니다.
class ChessSudokuValidator {
  static const int BOARD_SIZE = 9;

  /// 현재 셀에 숫자를 놓는 것이 유효한지 검사
  static bool isValidMove(List<List<int>> board,
      List<List<CellContent>> chessPieces, int row, int col) {
    final number = board[row][col];
    if (number == 0) return false;

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

  /// 전체 보드가 체스도쿠 규칙에 맞는지 검증
  static bool isValidBoard(List<List<CellContent>> board) {
    final size = board.length;

    // 1. 빈 셀이 있는지 확인 (완료 여부 체크용)
    bool hasEmptyNonChessCell = false;

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        if (!board[row][col].hasChessPiece && !board[row][col].hasNumber) {
          hasEmptyNonChessCell = true;
          break;
        }
      }
      if (hasEmptyNonChessCell) break;
    }

    // 빈 셀이 있으면 (미완성된 퍼즐) 현재까지 입력된 숫자들의 유효성만 검사
    // 빈 셀이 없으면 (완성된 퍼즐) 전체 규칙 검사

    // 2. 기본 스도쿠 규칙 검증 (행, 열, 3x3 박스)
    if (!_validateBasicSudokuRules(board)) {
      return false;
    }

    // 3. 체스 기물 규칙 검증
    if (!_validateChessPieceRules(board)) {
      return false;
    }

    // 빈 셀이 있으면 아직 미완성이므로 false 반환
    if (hasEmptyNonChessCell) {
      return false;
    }

    return true;
  }

  /// 기본 스도쿠 규칙 검증 (한 셀에 대해)
  static bool _isValidSudokuPlacement(List<List<int>> board, int row, int col) {
    final number = board[row][col];

    // 행 검증
    for (int c = 0; c < BOARD_SIZE; c++) {
      if (c != col && board[row][c] == number) {
        return false;
      }
    }

    // 열 검증
    for (int r = 0; r < BOARD_SIZE; r++) {
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

  /// 체스 기물 규칙 검증 (한 셀에 대해)
  static bool _isValidChessPiecePlacement(List<List<int>> board,
      List<List<CellContent>> chessPieces, int row, int col) {
    final number = board[row][col];

    // 체스 기물 규칙 검증
    for (int r = 0; r < BOARD_SIZE; r++) {
      for (int c = 0; c < BOARD_SIZE; c++) {
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

  /// 기본 스도쿠 규칙 검증 (전체 보드)
  static bool _validateBasicSudokuRules(List<List<CellContent>> board) {
    // 각 행 검증
    for (int row = 0; row < BOARD_SIZE; row++) {
      final usedNumbers = <int>{};
      for (int col = 0; col < BOARD_SIZE; col++) {
        if (board[row][col].hasNumber) {
          final number = board[row][col].number!;
          if (usedNumbers.contains(number)) {
            return false;
          }
          usedNumbers.add(number);
        }
      }
    }

    // 각 열 검증
    for (int col = 0; col < BOARD_SIZE; col++) {
      final usedNumbers = <int>{};
      for (int row = 0; row < BOARD_SIZE; row++) {
        if (board[row][col].hasNumber) {
          final number = board[row][col].number!;
          if (usedNumbers.contains(number)) {
            return false;
          }
          usedNumbers.add(number);
        }
      }
    }

    // 각 3x3 박스 검증
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final usedNumbers = <int>{};
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            final row = boxRow * 3 + r;
            final col = boxCol * 3 + c;
            if (board[row][col].hasNumber) {
              final number = board[row][col].number!;
              if (usedNumbers.contains(number)) {
                return false;
              }
              usedNumbers.add(number);
            }
          }
        }
      }
    }

    return true;
  }

  /// 체스 기물 규칙 검증 (전체 보드)
  static bool _validateChessPieceRules(List<List<CellContent>> board) {
    for (int pieceRow = 0; pieceRow < BOARD_SIZE; pieceRow++) {
      for (int pieceCol = 0; pieceCol < BOARD_SIZE; pieceCol++) {
        // 체스 기물이 있는 셀만 검사
        if (!board[pieceRow][pieceCol].hasChessPiece) {
          continue;
        }

        final chessPiece = board[pieceRow][pieceCol].chessPiece!;

        // 이 기물의 공격 범위에 있는 모든 셀 쌍을 검사
        for (int row1 = 0; row1 < BOARD_SIZE; row1++) {
          for (int col1 = 0; col1 < BOARD_SIZE; col1++) {
            // 이 셀이 체스 기물이면 건너뜀
            if (board[row1][col1].hasChessPiece) {
              continue;
            }

            // 첫 번째 셀이 기물의 공격 범위에 있는지 확인
            if (!_canPieceAttack(chessPiece, pieceRow, pieceCol, row1, col1)) {
              continue;
            }

            // 첫 번째 셀의 숫자 확인 (비어 있으면 건너뜀)
            if (!board[row1][col1].hasNumber) {
              continue;
            }

            // 두 번째 셀 검사
            for (int row2 = 0; row2 < BOARD_SIZE; row2++) {
              for (int col2 = 0; col2 < BOARD_SIZE; col2++) {
                // 같은 셀이거나 체스 기물이면 건너뜀
                if ((row1 == row2 && col1 == col2) ||
                    board[row2][col2].hasChessPiece) {
                  continue;
                }

                // 두 번째 셀도 기물의 공격 범위에 있는지 확인
                if (!_canPieceAttack(
                    chessPiece, pieceRow, pieceCol, row2, col2)) {
                  continue;
                }

                // 두 번째 셀의 숫자 확인 (비어 있으면 건너뜀)
                if (!board[row2][col2].hasNumber) {
                  continue;
                }

                // 두 셀의 숫자가 같으면 체스 규칙 위반
                if (board[row1][col1].number == board[row2][col2].number) {
                  return false;
                }
              }
            }
          }
        }
      }
    }

    return true;
  }

  /// 체스 기물이 특정 위치를 공격할 수 있는지 확인
  static bool _canPieceAttack(ChessPiece piece, int pieceRow, int pieceCol,
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

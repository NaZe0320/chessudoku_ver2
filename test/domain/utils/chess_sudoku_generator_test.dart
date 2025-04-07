import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generateBoard 결과 출력', () {
    final generator = ChessSudokuGenerator();
    final board = generator.generateBoard(Difficulty.easy);

    // 보드의 각 셀 내용을 자세히 출력
    for (int i = 0; i < board.length; i++) {
      String rowStr = '';
      for (int j = 0; j < board[i].length; j++) {
        final cell = board[i][j];
        if (cell.hasChessPiece) {
          final pieceType = cell.chessPiece.toString().split('.').last;
          // 기물 이름의 첫 글자만 사용
          String pieceSymbol = '';
          switch (pieceType) {
            case 'king':
              pieceSymbol = 'K';
              break;
            case 'queen':
              pieceSymbol = 'Q';
              break;
            case 'bishop':
              pieceSymbol = 'B';
              break;
            case 'knight':
              pieceSymbol = 'N';
              break;
            case 'rook':
              pieceSymbol = 'R';
              break;
            default:
              pieceSymbol = '?';
          }
          rowStr += '[$pieceSymbol]';
        } else if (cell.hasNumber) {
          rowStr += '[${cell.number}]';
        } else {
          rowStr += '[ ]';
        }
      }
      print('$i: $rowStr');
    }
  });
}

import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generateBoard 결과 출력', () {
    final generator = ChessSudokuGenerator();

    // 시간 측정 시작
    final stopwatch = Stopwatch()..start();

    final board = generator.generateBoard(Difficulty.hard);

    // 시간 측정 종료
    stopwatch.stop();

    print('=========== 체스도쿠 생성 결과 ===========');

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
    // 초기 힌트 숫자 개수 계산
    int initialHints = 0;
    int chessPieces = 0;
    for (final row in board) {
      for (final cell in row) {
        if (cell.hasNumber && cell.isInitial) {
          initialHints++;
        }
        if (cell.hasChessPiece) {
          chessPieces++;
        }
      }
    }

    // 결과 요약 출력
    print('\n=========== 생성 결과 요약 ===========');
    print('체스 기물 개수: $chessPieces');
    print('초기 힌트 숫자: $initialHints개');
    print('빈 칸(풀이 대상): ${81 - initialHints - chessPieces}개');
    print('생성 소요 시간: ${stopwatch.elapsedMilliseconds}ms');
  });
}

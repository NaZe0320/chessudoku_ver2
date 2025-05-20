import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/core/utils/chess_sudoku_generator.dart';
import 'package:chessudoku/core/utils/chess_sudoku_solver.dart'; // 외부 ChessSudokuSolver 클래스 가져오기
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChessSudoku Generation', () {
    // Chess Sudoku 생성기 테스트
    // ...기존 테스트 코드...

    // 생성된 퍼즐이 풀이 가능한지 확인
    test('Generated puzzle is solvable', () async {
      // 쉬운 난이도로 퍼즐 생성
      final generator = ChessSudokuGenerator();
      final puzzle = await generator.generatePuzzle(Difficulty.easy);

      expect(puzzle, isNotNull);
      expect(puzzle.length, equals(9));
      expect(puzzle[0].length, equals(9));

      // 솔버를 이용해 퍼즐 풀이 시도
      final solver = ChessSudokuSolver(puzzle);
      expect(solver.solve(), isTrue);
    });
  });
}

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChessSudokuGenerator Tests', () {
    // 테스트용 체스도쿠 생성기 인스턴스
    late ChessSudokuGenerator generator;

    setUp(() {
      generator = ChessSudokuGenerator();
    });

    test('체스도쿠 보드 생성 및 완전성 검증', () {
      // 난이도별 테스트 실행
      for (final difficulty in Difficulty.values) {
        // 체스도쿠 보드 생성
        final board = generator.generateBoard(difficulty);

        // 보드 크기 검증
        expect(board.length, ChessSudokuGenerator.BOARD_SIZE);
        for (final row in board) {
          expect(row.length, ChessSudokuGenerator.BOARD_SIZE);
        }

        // 각 셀의 내용 출력 (디버깅용)
        print('[$difficulty] 체스도쿠 보드:');
        _printBoard(board);

        // 체스 기물 배치 검증
        int chessPieceCount = 0;
        for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
          for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
            if (board[row][col].hasChessPiece) {
              chessPieceCount++;
              print('체스 기물: ${board[row][col].chessPiece} at ($row, $col)');
            }
          }
        }
        print('총 체스 기물 개수: $chessPieceCount');

        // 기본 검증: 모든 셀이 숫자 또는 체스 기물을 가져야 함
        for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
          for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
            final cell = board[row][col];
            expect(cell.hasNumber || cell.hasChessPiece, isTrue,
                reason: '셀 ($row, $col)이 비어있습니다.');
          }
        }

        // ChessSudokuValidator를 사용하여 보드의 유효성 검증
        final isValid = _validateBoard(board);
        expect(isValid, isTrue, reason: '체스도쿠 규칙에 맞지 않는 보드가 생성되었습니다.');
      }
    });

    test('체스 기물 제약 조건 테스트', () {
      // 특정 케이스를 위한 보드 설정
      final testCases = [
        _createTestBoardWithKnight(),
        _createTestBoardWithRook(),
        _createTestBoardWithBishop(),
        _createTestBoardWithQueen(),
        _createTestBoardWithKing(),
      ];

      // 각 테스트 케이스 실행
      for (int i = 0; i < testCases.length; i++) {
        final testBoard = testCases[i];
        print('테스트 케이스 ${i + 1}:');
        _printBoard(testBoard);

        // 보드 유효성 검증
        final isValid = _validateBoard(testBoard);
        expect(isValid, isTrue,
            reason: '테스트 케이스 ${i + 1}: 체스도쿠 규칙에 맞지 않는 보드입니다.');
      }
    });
  });
}

// 보드 콘솔 출력 헬퍼 함수
void _printBoard(List<List<CellContent>> board) {
  for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
    String rowStr = '';
    for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
      final cell = board[row][col];
      if (cell.hasChessPiece) {
        // 체스 기물을 약자로 표시 (K: 킹, Q: 퀸, R: 룩, B: 비숍, N: 나이트)
        switch (cell.chessPiece) {
          case ChessPiece.king:
            rowStr += 'K ';
            break;
          case ChessPiece.queen:
            rowStr += 'Q ';
            break;
          case ChessPiece.rook:
            rowStr += 'R ';
            break;
          case ChessPiece.bishop:
            rowStr += 'B ';
            break;
          case ChessPiece.knight:
            rowStr += 'N ';
            break;
          default:
            rowStr += '? ';
        }
      } else if (cell.hasNumber) {
        rowStr += '${cell.number} ';
      } else {
        rowStr += '0 ';
      }
    }
    print(rowStr);
  }
  print('');
}

// 체스도쿠 보드 유효성 검증 헬퍼 함수
bool _validateBoard(List<List<CellContent>> board) {
  // 각 행 검증
  for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
    final usedNumbers = <int>{};
    for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
      if (board[row][col].hasNumber) {
        final number = board[row][col].number!;
        if (usedNumbers.contains(number)) {
          print('행 $row에 중복된 숫자 $number가 있습니다.');
          return false;
        }
        usedNumbers.add(number);
      }
    }
  }

  // 각 열 검증
  for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
    final usedNumbers = <int>{};
    for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
      if (board[row][col].hasNumber) {
        final number = board[row][col].number!;
        if (usedNumbers.contains(number)) {
          print('열 $col에 중복된 숫자 $number가 있습니다.');
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
              print('박스 ($boxRow, $boxCol)에 중복된 숫자 $number가 있습니다.');
              return false;
            }
            usedNumbers.add(number);
          }
        }
      }
    }
  }

  // 체스 기물 규칙 검증
  for (int pieceRow = 0;
      pieceRow < ChessSudokuGenerator.BOARD_SIZE;
      pieceRow++) {
    for (int pieceCol = 0;
        pieceCol < ChessSudokuGenerator.BOARD_SIZE;
        pieceCol++) {
      if (board[pieceRow][pieceCol].hasChessPiece) {
        final piece = board[pieceRow][pieceCol].chessPiece!;

        // 이 기물의 공격 범위에 있는 모든 셀 쌍을 검사
        for (int r1 = 0; r1 < ChessSudokuGenerator.BOARD_SIZE; r1++) {
          for (int c1 = 0; c1 < ChessSudokuGenerator.BOARD_SIZE; c1++) {
            // 첫 번째 셀이 체스 기물이면 건너뜀
            if (board[r1][c1].hasChessPiece) continue;

            // 첫 번째 셀이 기물의 공격 범위에 있는지 확인
            if (!_canPieceAttack(piece, pieceRow, pieceCol, r1, c1)) continue;

            // 첫 번째 셀의 숫자 확인
            if (!board[r1][c1].hasNumber) continue;
            final number = board[r1][c1].number!;

            // 두 번째 셀을 순회하며 같은 기물의 공격 범위에 있고 같은 숫자를 가진 셀이 있는지 검사
            for (int r2 = 0; r2 < ChessSudokuGenerator.BOARD_SIZE; r2++) {
              for (int c2 = 0; c2 < ChessSudokuGenerator.BOARD_SIZE; c2++) {
                // 같은 셀이거나 체스 기물이면 건너뜀
                if ((r1 == r2 && c1 == c2) || board[r2][c2].hasChessPiece)
                  continue;

                // 두 번째 셀도 기물의 공격 범위에 있는지 확인
                if (!_canPieceAttack(piece, pieceRow, pieceCol, r2, c2))
                  continue;

                // 두 번째 셀의 숫자 확인
                if (!board[r2][c2].hasNumber) continue;

                // 두 셀의 숫자가 같으면 체스 규칙 위반
                if (board[r2][c2].number == number) {
                  print(
                      '체스 기물 $piece ($pieceRow, $pieceCol)의 공격 범위에 있는 두 셀 ($r1, $c1)와 ($r2, $c2)에 같은 숫자 $number가 있습니다.');
                  return false;
                }
              }
            }
          }
        }
      }
    }
  }

  return true;
}

// 체스 기물이 특정 위치를 공격할 수 있는지 확인하는 함수
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

// 테스트용 보드 생성 함수들

// 나이트 테스트 보드
List<List<CellContent>> _createTestBoardWithKnight() {
  final board = List.generate(
    ChessSudokuGenerator.BOARD_SIZE,
    (_) => List.generate(
      ChessSudokuGenerator.BOARD_SIZE,
      (_) => const CellContent(isInitial: true),
    ),
  );

  // 나이트 배치
  board[4][4] =
      const CellContent(chessPiece: ChessPiece.knight, isInitial: true);

  // 숫자 배치 (나이트 공격 범위에 같은 숫자 없도록)
  // 나이트 공격 범위: (2,3), (2,5), (3,2), (3,6), (5,2), (5,6), (6,3), (6,5)
  board[2][3] = const CellContent(number: 1, isInitial: true);
  board[2][5] = const CellContent(number: 2, isInitial: true);
  board[3][2] = const CellContent(number: 3, isInitial: true);
  board[3][6] = const CellContent(number: 4, isInitial: true);
  board[5][2] = const CellContent(number: 5, isInitial: true);
  board[5][6] = const CellContent(number: 6, isInitial: true);
  board[6][3] = const CellContent(number: 7, isInitial: true);
  board[6][5] = const CellContent(number: 8, isInitial: true);

  // 다른 셀들에 숫자 채우기
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    for (int j = 0; j < ChessSudokuGenerator.BOARD_SIZE; j++) {
      if (!board[i][j].hasChessPiece && !board[i][j].hasNumber) {
        // 간단한 패턴으로 채우기
        board[i][j] = CellContent(number: (i + j) % 9 + 1, isInitial: true);
      }
    }
  }

  return board;
}

// 룩 테스트 보드
List<List<CellContent>> _createTestBoardWithRook() {
  final board = List.generate(
    ChessSudokuGenerator.BOARD_SIZE,
    (_) => List.generate(
      ChessSudokuGenerator.BOARD_SIZE,
      (_) => const CellContent(isInitial: true),
    ),
  );

  // 룩 배치
  board[4][4] = const CellContent(chessPiece: ChessPiece.rook, isInitial: true);

  // 숫자 배치 (같은 행/열에 같은 숫자 없도록)
  // 4행: 각기 다른 숫자
  for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
    if (col != 4) {
      // 룩 위치 제외
      board[4][col] = CellContent(number: col + 1, isInitial: true);
    }
  }

  // 4열: 각기 다른 숫자
  for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
    if (row != 4) {
      // 룩 위치 제외
      board[row][4] = CellContent(number: row + 1, isInitial: true);
    }
  }

  // 나머지 셀 채우기
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    for (int j = 0; j < ChessSudokuGenerator.BOARD_SIZE; j++) {
      if (!board[i][j].hasChessPiece && !board[i][j].hasNumber) {
        board[i][j] = CellContent(number: (i * 3 + j) % 9 + 1, isInitial: true);
      }
    }
  }

  return board;
}

// 비숍 테스트 보드
List<List<CellContent>> _createTestBoardWithBishop() {
  final board = List.generate(
    ChessSudokuGenerator.BOARD_SIZE,
    (_) => List.generate(
      ChessSudokuGenerator.BOARD_SIZE,
      (_) => const CellContent(isInitial: true),
    ),
  );

  // 비숍 배치
  board[4][4] =
      const CellContent(chessPiece: ChessPiece.bishop, isInitial: true);

  // 대각선 방향에 다른 숫자 채우기
  // 좌상->우하 대각선
  int num = 1;
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    if (0 <= i &&
        i < ChessSudokuGenerator.BOARD_SIZE &&
        0 <= i &&
        i < ChessSudokuGenerator.BOARD_SIZE &&
        !(i == 4 && i == 4)) {
      // 비숍 위치 제외
      board[i][i] = CellContent(number: num++, isInitial: true);
      if (num > 9) num = 1;
    }
  }

  // 우상->좌하 대각선
  num = 9;
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    int j = ChessSudokuGenerator.BOARD_SIZE - 1 - i;
    if (0 <= i &&
        i < ChessSudokuGenerator.BOARD_SIZE &&
        0 <= j &&
        j < ChessSudokuGenerator.BOARD_SIZE &&
        !(i == 4 && j == 4)) {
      // 비숍 위치 제외
      board[i][j] = CellContent(number: num--, isInitial: true);
      if (num < 1) num = 9;
    }
  }

  // 나머지 셀 채우기
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    for (int j = 0; j < ChessSudokuGenerator.BOARD_SIZE; j++) {
      if (!board[i][j].hasChessPiece && !board[i][j].hasNumber) {
        board[i][j] =
            CellContent(number: (i * 2 + j * 3) % 9 + 1, isInitial: true);
      }
    }
  }

  return board;
}

// 퀸 테스트 보드
List<List<CellContent>> _createTestBoardWithQueen() {
  final board = List.generate(
    ChessSudokuGenerator.BOARD_SIZE,
    (_) => List.generate(
      ChessSudokuGenerator.BOARD_SIZE,
      (_) => const CellContent(isInitial: true),
    ),
  );

  // 퀸 배치
  board[4][4] =
      const CellContent(chessPiece: ChessPiece.queen, isInitial: true);

  // 가로, 세로, 대각선 방향에 각기 다른 숫자 배치
  // 4행
  for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
    if (col != 4) {
      board[4][col] = CellContent(number: col + 1, isInitial: true);
    }
  }

  // 4열
  for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
    if (row != 4) {
      board[row][4] = CellContent(number: row + 1, isInitial: true);
    }
  }

  // 좌상->우하 대각선
  int offset = 0;
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    if (i != 4) {
      int diff = i - 4;
      int row = i;
      int col = i;
      if (0 <= row &&
          row < ChessSudokuGenerator.BOARD_SIZE &&
          0 <= col &&
          col < ChessSudokuGenerator.BOARD_SIZE) {
        board[row][col] =
            CellContent(number: (offset++ % 9) + 1, isInitial: true);
      }
    }
  }

  // 우상->좌하 대각선
  offset = 0;
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    int j = ChessSudokuGenerator.BOARD_SIZE - 1 - i;
    if (i != 4 && j != 4) {
      if (0 <= i &&
          i < ChessSudokuGenerator.BOARD_SIZE &&
          0 <= j &&
          j < ChessSudokuGenerator.BOARD_SIZE) {
        board[i][j] = CellContent(number: (offset++ % 9) + 1, isInitial: true);
      }
    }
  }

  // 나머지 셀 채우기
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    for (int j = 0; j < ChessSudokuGenerator.BOARD_SIZE; j++) {
      if (!board[i][j].hasChessPiece && !board[i][j].hasNumber) {
        board[i][j] =
            CellContent(number: (i * 4 + j * 5) % 9 + 1, isInitial: true);
      }
    }
  }

  return board;
}

// 킹 테스트 보드
List<List<CellContent>> _createTestBoardWithKing() {
  final board = List.generate(
    ChessSudokuGenerator.BOARD_SIZE,
    (_) => List.generate(
      ChessSudokuGenerator.BOARD_SIZE,
      (_) => const CellContent(isInitial: true),
    ),
  );

  // 킹 배치
  board[4][4] = const CellContent(chessPiece: ChessPiece.king, isInitial: true);

  // 킹 주변 8칸에 서로 다른 숫자 배치
  int num = 1;
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      if (i == 0 && j == 0) continue; // 킹 위치 제외

      int row = 4 + i;
      int col = 4 + j;
      if (0 <= row &&
          row < ChessSudokuGenerator.BOARD_SIZE &&
          0 <= col &&
          col < ChessSudokuGenerator.BOARD_SIZE) {
        board[row][col] = CellContent(number: num++, isInitial: true);
      }
    }
  }

  // 나머지 셀 채우기
  for (int i = 0; i < ChessSudokuGenerator.BOARD_SIZE; i++) {
    for (int j = 0; j < ChessSudokuGenerator.BOARD_SIZE; j++) {
      if (!board[i][j].hasChessPiece && !board[i][j].hasNumber) {
        board[i][j] = CellContent(number: (i + j * 2) % 9 + 1, isInitial: true);
      }
    }
  }

  return board;
}

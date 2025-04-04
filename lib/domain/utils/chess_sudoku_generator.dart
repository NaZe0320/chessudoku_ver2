import 'dart:math';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_validator.dart';

/// 체스도쿠 퍼즐 생성기
///
/// 체스도쿠 규칙에 맞는 유효한 퍼즐을 효율적으로 생성합니다.
/// 백트래킹 알고리즘과 최적화 기법을 사용하여 빠른 생성 속도를 보장합니다.
class ChessSudokuGenerator {
  static const int BOARD_SIZE = 9;
  final Random _random = Random();

  /// 난이도에 따른 총 체스 기물 개수 범위 설정
  /// 난이도가 높을수록 더 많은 체스 기물이 배치됩니다.
  Map<String, int> _getChessPiecesCountRange(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        // 쉬움: 총 3-5개의 기물
        return {'min': 3, 'max': 5};
      case Difficulty.medium:
        // 보통: 총 5-8개의 기물
        return {'min': 5, 'max': 8};
      case Difficulty.hard:
        // 어려움: 총 8-12개의 기물
        return {'min': 8, 'max': 12};
    }
  }

  /// 각 체스 기물 별 개수 범위 설정
  Map<ChessPiece, Map<String, int>> _getPieceTypeCountRanges(
      Difficulty difficulty) {
    final ranges = <ChessPiece, Map<String, int>>{};

    // 각 기물 별 개수 범위 설정
    switch (difficulty) {
      case Difficulty.easy:
        // 쉬움: 기물당 0-2개씩만 배치
        for (final piece in ChessPiece.values) {
          ranges[piece] = {'min': 0, 'max': 2};
        }
        break;

      case Difficulty.medium:
        // 보통: 기물당 0-3개씩 배치, 퀸과 킹은 적게
        for (final piece in ChessPiece.values) {
          if (piece == ChessPiece.queen || piece == ChessPiece.king) {
            ranges[piece] = {'min': 0, 'max': 2};
          } else {
            ranges[piece] = {'min': 0, 'max': 3};
          }
        }
        break;

      case Difficulty.hard:
        // 어려움: 모든 종류의 기물이 최소 1개씩은 포함되도록 함
        for (final piece in ChessPiece.values) {
          if (piece == ChessPiece.queen) {
            ranges[piece] = {'min': 1, 'max': 2}; // 퀸은 강력해서 적게
          } else if (piece == ChessPiece.king) {
            ranges[piece] = {'min': 1, 'max': 3}; // 킹도 약간 제한
          } else {
            ranges[piece] = {'min': 1, 'max': 4}; // 나머지는 더 많이
          }
        }
        break;
    }

    return ranges;
  }

  /// 난이도에 따른 미리 채워진 숫자 개수 설정
  /// 난이도가 높을수록 미리 채워진 숫자가 적어 더 어려워집니다.
  int _getFilledNumbersCount(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 25; // 쉬움: 더 적은 힌트로 수정
      case Difficulty.medium:
        return 20; // 보통: 더 적은 힌트로 수정
      case Difficulty.hard:
        return 15; // 어려움: 더 적은 힌트로 수정
    }
  }

  /// 체스도쿠 보드 생성 메인 메서드
  /// 체스 기물 배치 후 체스 기물의 제약 조건을 고려하여 스도쿠 규칙에 맞게 숫자를 채워 완성된 보드를 생성합니다.
  List<List<CellContent>> generateBoard(Difficulty difficulty) {
    // 빈 보드 초기화
    final emptyBoard = List.generate(
      BOARD_SIZE,
      (_) => List.generate(
        BOARD_SIZE,
        (_) => const CellContent(isInitial: false),
      ),
    );

    // 1. 체스 기물 배치
    final chessPiecesLocations = _generateChessPiecesLocations(difficulty);
    final boardWithChessPieces =
        _placeChessPiecesOnBoard(emptyBoard, chessPiecesLocations);

    // 2. 체스 기물의 제약 조건을 고려한 스도쿠 솔루션 생성
    final sudokuSolution = _generateChessSudokuSolution(chessPiecesLocations);

    // 3. 체스 기물이 있는 위치를 제외하고 기본 솔루션 적용
    final completedBoard = List.generate(
      BOARD_SIZE,
      (row) => List.generate(
        BOARD_SIZE,
        (col) {
          // 체스 기물이 있는 셀은 그대로 유지
          if (boardWithChessPieces[row][col].hasChessPiece) {
            return boardWithChessPieces[row][col].copyWith();
          }

          // 체스 기물이 없는 셀에는 스도쿠 솔루션의 숫자 적용
          return CellContent(number: sudokuSolution[row][col], isInitial: true);
        },
      ),
    );

    return completedBoard;
  }

  /// 보드에 체스 기물 배치
  List<List<CellContent>> _placeChessPiecesOnBoard(
      List<List<CellContent>> board,
      List<Map<String, dynamic>> chessPiecesLocations) {
    // 보드 복사
    final result = List.generate(
      BOARD_SIZE,
      (row) => List.generate(
        BOARD_SIZE,
        (col) => board[row][col].copyWith(),
      ),
    );

    // 체스 기물 위치에 기물 배치
    for (final location in chessPiecesLocations) {
      final row = location['row'] as int;
      final col = location['col'] as int;
      final piece = location['piece'] as ChessPiece;

      result[row][col] = CellContent(chessPiece: piece, isInitial: true);
    }

    return result;
  }

  /// 체스 기물을 배치할 위치 결정
  List<Map<String, dynamic>> _generateChessPiecesLocations(
      Difficulty difficulty) {
    final totalCountRange = _getChessPiecesCountRange(difficulty);
    final pieceTypeRanges = _getPieceTypeCountRanges(difficulty);
    final locations = <Map<String, dynamic>>[];

    // 전체 기물 개수 결정 (범위 내에서 랜덤)
    final totalPiecesCount =
        _random.nextInt(totalCountRange['max']! - totalCountRange['min']! + 1) +
            totalCountRange['min']!;

    // 각 기물 타입별 개수 결정
    final pieceTypeCounts = <ChessPiece, int>{};
    int remainingPieces = totalPiecesCount;

    // 우선 각 기물의 최소 개수 할당
    for (final piece in ChessPiece.values) {
      final minCount = pieceTypeRanges[piece]!['min']!;
      pieceTypeCounts[piece] = minCount;
      remainingPieces -= minCount;
    }

    // 남은 기물을 랜덤하게 할당
    while (remainingPieces > 0) {
      // 아직 최대 개수에 도달하지 않은 기물 타입들 찾기
      final availablePieceTypes = ChessPiece.values.where((piece) {
        return pieceTypeCounts[piece]! < pieceTypeRanges[piece]!['max']!;
      }).toList();

      // 더 이상 추가할 수 있는 기물 타입이 없으면 종료
      if (availablePieceTypes.isEmpty) break;

      // 랜덤하게 기물 타입 선택하여 추가
      final randomPiece =
          availablePieceTypes[_random.nextInt(availablePieceTypes.length)];
      pieceTypeCounts[randomPiece] = pieceTypeCounts[randomPiece]! + 1;
      remainingPieces--;
    }

    // 체스 기물을 무작위로 배치할 위치 선택
    final positions = <List<int>>[];
    for (int row = 0; row < BOARD_SIZE; row++) {
      for (int col = 0; col < BOARD_SIZE; col++) {
        positions.add([row, col]);
      }
    }

    // 위치 랜덤하게 섞기
    _shuffleList(positions);

    // 기물 타입별 개수에 따라 위치에 배치
    int positionIndex = 0;
    for (final piece in ChessPiece.values) {
      final count = pieceTypeCounts[piece]!;
      for (int i = 0; i < count; i++) {
        if (positionIndex >= positions.length) break;

        final position = positions[positionIndex++];
        final row = position[0];
        final col = position[1];

        locations.add({
          'row': row,
          'col': col,
          'piece': piece,
        });
      }
    }

    return locations;
  }

  /// 리스트 셔플 (Fisher-Yates 알고리즘)
  void _shuffleList<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  /// 체스도쿠 퍼즐 생성 (스도쿠 + 체스 기물 제약)
  List<List<int>> _generateChessSudokuSolution(
      List<Map<String, dynamic>> chessPiecesLocations) {
    // 9x9 보드 초기화
    final solution = List.generate(
      BOARD_SIZE,
      (_) => List.generate(BOARD_SIZE, (_) => 0),
    );

    // 체스 기물 정보를 별도로 저장
    _chessPiecesLocations = chessPiecesLocations;

    // 대각선 블록부터 채우기 (독립적으로 채울 수 있음)
    _fillDiagonalBoxes(solution);

    // 나머지 스도쿠 채우기 (체스 기물 제약 포함)
    _solveSudoku(solution, 0, 0);

    return solution;
  }

  /// 체스 기물 배치 정보 저장
  List<Map<String, dynamic>> _chessPiecesLocations = [];

  /// 체스 기물 규칙에 맞는 숫자 배치인지 확인
  bool _isValidChessPiecePlacement(List<List<int>> board, int row, int col) {
    final num = board[row][col];

    // 체스 기물 위치와 타입에 따른 제약 조건 검사
    for (final pieceInfo in _chessPiecesLocations) {
      final pieceRow = pieceInfo['row'] as int;
      final pieceCol = pieceInfo['col'] as int;
      final piece = pieceInfo['piece'] as ChessPiece;

      // 현재 셀이 체스 기물의 공격 범위에 있는지 확인
      if (_canPieceAttack(piece, pieceRow, pieceCol, row, col)) {
        // 다른 셀들 중에서 같은 기물의 공격 범위에 있는 셀 검사
        for (int r = 0; r < BOARD_SIZE; r++) {
          for (int c = 0; c < BOARD_SIZE; c++) {
            // 자기 자신이거나 빈 셀이면 건너뛰기
            if ((r == row && c == col) || board[r][c] == 0) {
              continue;
            }

            // 해당 셀도 같은 기물의 공격 범위에 있는지 확인
            if (_canPieceAttack(piece, pieceRow, pieceCol, r, c)) {
              // 같은 숫자가 있으면 유효하지 않음
              if (board[r][c] == num) {
                return false;
              }
            }
          }
        }
      }
    }

    return true;
  }

  /// 대각선 블록 채우기 (1, 5, 9번 블록)
  void _fillDiagonalBoxes(List<List<int>> board) {
    for (int boxIndex = 0; boxIndex < 3; boxIndex++) {
      final startRow = boxIndex * 3;
      final startCol = boxIndex * 3;

      final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      _shuffleList(numbers);

      int index = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          board[startRow + i][startCol + j] = numbers[index++];
        }
      }
    }
  }

  /// 스도쿠 완성하기 (백트래킹)
  bool _solveSudoku(List<List<int>> board, int row, int col) {
    // 모든 행을 완료했다면 완료
    if (row == BOARD_SIZE) {
      return true;
    }

    // 다음 셀로 이동
    int nextRow = col == BOARD_SIZE - 1 ? row + 1 : row;
    int nextCol = col == BOARD_SIZE - 1 ? 0 : col + 1;

    // 이미 숫자가 있으면 다음 셀로 건너뜀
    if (board[row][col] != 0) {
      return _solveSudoku(board, nextRow, nextCol);
    }

    // 가능한 숫자 시도 (1-9)
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    _shuffleList(numbers);

    for (final num in numbers) {
      // 스도쿠 규칙에 맞는지 확인
      if (_isValidSudokuPlacement(board, row, col, num)) {
        // 임시로 숫자 할당
        board[row][col] = num;

        // 체스 기물 규칙도 검사
        if (_isValidChessPiecePlacement(board, row, col)) {
          // 다음 셀로 진행
          if (_solveSudoku(board, nextRow, nextCol)) {
            return true;
          }
        }

        // 실패하면 백트래킹
        board[row][col] = 0;
      }
    }

    // 해결책을 찾지 못했으면 백트래킹
    return false;
  }

  /// 스도쿠 규칙에 맞는 숫자 배치인지 확인
  bool _isValidSudokuPlacement(
      List<List<int>> board, int row, int col, int num) {
    // 행 검사
    for (int c = 0; c < BOARD_SIZE; c++) {
      if (board[row][c] == num) {
        return false;
      }
    }

    // 열 검사
    for (int r = 0; r < BOARD_SIZE; r++) {
      if (board[r][col] == num) {
        return false;
      }
    }

    // 3x3 박스 검사
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[boxRow + r][boxCol + c] == num) {
          return false;
        }
      }
    }

    return true;
  }

  /// 체스 기물이 특정 위치를 공격할 수 있는지 확인
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

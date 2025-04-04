import 'dart:math';

// 원본 클래스의 간략화된 버전을 복제합니다.
// CellContent 클래스 정의
class CellContent {
  final int? number;
  final ChessPiece? chessPiece;
  final bool isInitial;

  const CellContent({this.number, this.chessPiece, this.isInitial = false});

  bool get hasNumber => number != null;
  bool get hasChessPiece => chessPiece != null;

  CellContent copyWith({int? number, ChessPiece? chessPiece, bool? isInitial}) {
    return CellContent(
      number: number ?? this.number,
      chessPiece: chessPiece ?? this.chessPiece,
      isInitial: isInitial ?? this.isInitial,
    );
  }

  @override
  String toString() {
    if (hasChessPiece) {
      return 'Chess(${chessPiece.toString().split('.').last})';
    } else if (hasNumber) {
      return 'Number($number)';
    } else {
      return 'Empty';
    }
  }
}

// ChessPiece enum 정의
enum ChessPiece { knight, rook, bishop, queen, king }

// Difficulty enum 정의
enum Difficulty { easy, medium, hard }

// 체스도쿠 생성기 클래스 정의
class ChessSudokuGenerator {
  static const int BOARD_SIZE = 9;
  final Random _random = Random();

  // 난이도별 체스 기물 개수 범위 설정
  Map<String, int> _getChessPiecesCountRange(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return {'min': 3, 'max': 5};
      case Difficulty.medium:
        return {'min': 5, 'max': 8};
      case Difficulty.hard:
        return {'min': 8, 'max': 12};
    }
  }

  // 체스 기물별 개수 범위 설정
  Map<ChessPiece, Map<String, int>> _getPieceTypeCountRanges(
      Difficulty difficulty) {
    final ranges = <ChessPiece, Map<String, int>>{};

    switch (difficulty) {
      case Difficulty.easy:
        for (final piece in ChessPiece.values) {
          ranges[piece] = {'min': 0, 'max': 2};
        }
        break;

      case Difficulty.medium:
        for (final piece in ChessPiece.values) {
          if (piece == ChessPiece.queen || piece == ChessPiece.king) {
            ranges[piece] = {'min': 0, 'max': 2};
          } else {
            ranges[piece] = {'min': 0, 'max': 3};
          }
        }
        break;

      case Difficulty.hard:
        for (final piece in ChessPiece.values) {
          if (piece == ChessPiece.queen) {
            ranges[piece] = {'min': 1, 'max': 2};
          } else if (piece == ChessPiece.king) {
            ranges[piece] = {'min': 1, 'max': 3};
          } else {
            ranges[piece] = {'min': 1, 'max': 4};
          }
        }
        break;
    }

    return ranges;
  }

  // 난이도별 힌트 개수 설정
  int _getFilledNumbersCount(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 25;
      case Difficulty.medium:
        return 20;
      case Difficulty.hard:
        return 15;
    }
  }

  // 메인 보드 생성 메서드
  List<List<CellContent>> generateBoard(Difficulty difficulty) {
    print('체스도쿠 보드 생성 시작 (난이도: $difficulty)');

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

    print('체스 기물 배치 완료: ${chessPiecesLocations.length}개');
    for (final loc in chessPiecesLocations) {
      print('  ${loc['piece']} at (${loc['row']}, ${loc['col']})');
    }

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

    print('체스도쿠 보드 생성 완료');
    return completedBoard;
  }

  // 체스 기물 배치 메서드
  List<List<CellContent>> _placeChessPiecesOnBoard(
      List<List<CellContent>> board,
      List<Map<String, dynamic>> chessPiecesLocations) {
    final result = List.generate(
      BOARD_SIZE,
      (row) => List.generate(
        BOARD_SIZE,
        (col) => board[row][col].copyWith(),
      ),
    );

    for (final location in chessPiecesLocations) {
      final row = location['row'] as int;
      final col = location['col'] as int;
      final piece = location['piece'] as ChessPiece;

      result[row][col] = CellContent(chessPiece: piece, isInitial: true);
    }

    return result;
  }

  // 체스 기물 위치 생성 메서드
  List<Map<String, dynamic>> _generateChessPiecesLocations(
      Difficulty difficulty) {
    final totalCountRange = _getChessPiecesCountRange(difficulty);
    final pieceTypeRanges = _getPieceTypeCountRanges(difficulty);
    final locations = <Map<String, dynamic>>[];

    final totalPiecesCount =
        _random.nextInt(totalCountRange['max']! - totalCountRange['min']! + 1) +
            totalCountRange['min']!;

    final pieceTypeCounts = <ChessPiece, int>{};
    int remainingPieces = totalPiecesCount;

    for (final piece in ChessPiece.values) {
      final minCount = pieceTypeRanges[piece]!['min']!;
      pieceTypeCounts[piece] = minCount;
      remainingPieces -= minCount;
    }

    while (remainingPieces > 0) {
      final availablePieceTypes = ChessPiece.values.where((piece) {
        return pieceTypeCounts[piece]! < pieceTypeRanges[piece]!['max']!;
      }).toList();

      if (availablePieceTypes.isEmpty) break;

      final randomPiece =
          availablePieceTypes[_random.nextInt(availablePieceTypes.length)];
      pieceTypeCounts[randomPiece] = pieceTypeCounts[randomPiece]! + 1;
      remainingPieces--;
    }

    final positions = <List<int>>[];
    for (int row = 0; row < BOARD_SIZE; row++) {
      for (int col = 0; col < BOARD_SIZE; col++) {
        positions.add([row, col]);
      }
    }

    _shuffleList(positions);

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

  // 리스트 셔플 메서드
  void _shuffleList<T>(List<T> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  // 체스 기물 배치 정보 저장
  List<Map<String, dynamic>> _chessPiecesLocations = [];

  // 체스도쿠 솔루션 생성 메서드
  List<List<int>> _generateChessSudokuSolution(
      List<Map<String, dynamic>> chessPiecesLocations) {
    final solution = List.generate(
      BOARD_SIZE,
      (_) => List.generate(BOARD_SIZE, (_) => 0),
    );

    _chessPiecesLocations = chessPiecesLocations;

    _fillDiagonalBoxes(solution);

    // 최대 시도 횟수를 늘림
    int maxAttempts = 20;
    bool solved = false;

    for (int attempt = 0; attempt < maxAttempts && !solved; attempt++) {
      if (attempt > 0) {
        print('솔루션 시도 #${attempt + 1} - 다시 시도 중...');
        // 보드 초기화
        for (int i = 0; i < BOARD_SIZE; i++) {
          for (int j = 0; j < BOARD_SIZE; j++) {
            solution[i][j] = 0;
          }
        }
        // 대각선 블록을 다른 패턴으로 채움
        _fillDiagonalBoxes(solution);
      }

      // 백트래킹 알고리즘 실행
      solved = _solveSudoku(solution, 0, 0);

      // 디버깅을 위해 진행 상황 출력
      if (attempt % 5 == 4 || solved) {
        print('시도 ${attempt + 1}/$maxAttempts - ${solved ? '성공' : '진행 중'}');
        int filledCount = 0;
        for (int i = 0; i < BOARD_SIZE; i++) {
          for (int j = 0; j < BOARD_SIZE; j++) {
            if (solution[i][j] != 0) filledCount++;
          }
        }
        print('채워진 셀: $filledCount/${BOARD_SIZE * BOARD_SIZE}');
      }
    }

    print('체스도쿠 솔루션 생성 ${solved ? '성공' : '실패'}');
    _printBoard(solution);

    // 솔루션을 찾지 못했다면 빈 셀(0)을 무작위 값으로 채움
    if (!solved) {
      print('솔루션을 찾지 못해 빈 셀을 임의의 값으로 채웁니다.');
      _fillEmptyCells(solution);
      _printBoard(solution);
    }

    return solution;
  }

  // 보드 출력 메서드
  void _printBoard(List<List<int>> board) {
    print('현재 보드 상태:');
    for (int i = 0; i < BOARD_SIZE; i++) {
      print(board[i].join(' '));
    }
    print('');
  }

  // 대각선 블록 채우기 메서드
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

  // 스도쿠 풀이 메서드
  bool _solveSudoku(List<List<int>> board, int row, int col) {
    if (row == BOARD_SIZE) {
      return true;
    }

    int nextRow = col == BOARD_SIZE - 1 ? row + 1 : row;
    int nextCol = col == BOARD_SIZE - 1 ? 0 : col + 1;

    if (board[row][col] != 0) {
      return _solveSudoku(board, nextRow, nextCol);
    }

    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    _shuffleList(numbers);

    for (final num in numbers) {
      if (_isValidSudokuPlacement(board, row, col, num)) {
        board[row][col] = num;

        if (_isValidChessPiecePlacement(board, row, col)) {
          if (_solveSudoku(board, nextRow, nextCol)) {
            return true;
          }
        }

        board[row][col] = 0;
      }
    }

    return false;
  }

  // 스도쿠 규칙 검증 메서드
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

  // 체스 기물 규칙 검증 메서드
  bool _isValidChessPiecePlacement(List<List<int>> board, int row, int col) {
    final num = board[row][col];

    for (final pieceInfo in _chessPiecesLocations) {
      final pieceRow = pieceInfo['row'] as int;
      final pieceCol = pieceInfo['col'] as int;
      final piece = pieceInfo['piece'] as ChessPiece;

      if (_canPieceAttack(piece, pieceRow, pieceCol, row, col)) {
        for (int r = 0; r < BOARD_SIZE; r++) {
          for (int c = 0; c < BOARD_SIZE; c++) {
            if ((r == row && c == col) || board[r][c] == 0) {
              continue;
            }

            if (_canPieceAttack(piece, pieceRow, pieceCol, r, c)) {
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

  // 체스 기물 공격 범위 검증 메서드
  bool _canPieceAttack(ChessPiece piece, int pieceRow, int pieceCol,
      int targetRow, int targetCol) {
    switch (piece) {
      case ChessPiece.knight:
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

      case ChessPiece.rook:
        return pieceRow == targetRow || pieceCol == targetCol;

      case ChessPiece.bishop:
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return rowDiff == colDiff;

      case ChessPiece.queen:
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return pieceRow == targetRow ||
            pieceCol == targetCol ||
            rowDiff == colDiff;

      case ChessPiece.king:
        final rowDiff = (pieceRow - targetRow).abs();
        final colDiff = (pieceCol - targetCol).abs();
        return rowDiff <= 1 && colDiff <= 1;
    }
  }

  // 빈 셀을 임의의 숫자로 채우는 메서드
  void _fillEmptyCells(List<List<int>> board) {
    for (int row = 0; row < BOARD_SIZE; row++) {
      for (int col = 0; col < BOARD_SIZE; col++) {
        if (board[row][col] == 0) {
          // 유효한 숫자 목록 찾기
          final validNumbers = <int>[];
          for (int num = 1; num <= 9; num++) {
            if (_isValidSudokuPlacement(board, row, col, num)) {
              validNumbers.add(num);
            }
          }

          // 유효한 숫자가 있으면 무작위로 선택
          if (validNumbers.isNotEmpty) {
            board[row][col] =
                validNumbers[_random.nextInt(validNumbers.length)];
          } else {
            // 없으면 그냥 무작위 숫자 배정 (비정상이지만 테스트 목적으로)
            board[row][col] = _random.nextInt(9) + 1;
          }
        }
      }
    }
  }
}

// 보드 콘솔 출력 헬퍼 함수
void printBoard(List<List<CellContent>> board) {
  for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
    String rowStr = '';
    for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
      final cell = board[row][col];
      if (cell.hasChessPiece) {
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

// 보드 유효성 검증 헬퍼 함수
bool validateBoard(List<List<CellContent>> board) {
  print('보드 유효성 검증 시작...');

  // 빈 셀 확인
  int emptyCount = 0;
  for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
    for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
      if (!board[row][col].hasChessPiece && !board[row][col].hasNumber) {
        emptyCount++;
      }
    }
  }

  if (emptyCount > 0) {
    print('경고: $emptyCount개의 빈 셀이 있습니다. 완전한 솔루션이 아닙니다.');
    return false;
  }

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

  print('스도쿠 기본 규칙 검증 통과');

  // 체스 기물 규칙 검증
  for (int pieceRow = 0;
      pieceRow < ChessSudokuGenerator.BOARD_SIZE;
      pieceRow++) {
    for (int pieceCol = 0;
        pieceCol < ChessSudokuGenerator.BOARD_SIZE;
        pieceCol++) {
      if (board[pieceRow][pieceCol].hasChessPiece) {
        final piece = board[pieceRow][pieceCol].chessPiece!;
        print('체스 기물 검증: $piece at ($pieceRow, $pieceCol)');

        // 이 기물의 공격 범위에 있는 모든 셀 검사
        for (int r1 = 0; r1 < ChessSudokuGenerator.BOARD_SIZE; r1++) {
          for (int c1 = 0; c1 < ChessSudokuGenerator.BOARD_SIZE; c1++) {
            // 첫 번째 셀이 체스 기물이면 건너뜀
            if (board[r1][c1].hasChessPiece) continue;

            // 첫 번째 셀이 기물의 공격 범위에 있는지 확인
            if (!canPieceAttack(piece, pieceRow, pieceCol, r1, c1)) continue;

            // 첫 번째 셀의 숫자 확인
            if (!board[r1][c1].hasNumber) continue;
            final number = board[r1][c1].number!;

            // 두 번째 셀 검사
            for (int r2 = 0; r2 < ChessSudokuGenerator.BOARD_SIZE; r2++) {
              for (int c2 = 0; c2 < ChessSudokuGenerator.BOARD_SIZE; c2++) {
                // 같은 셀이거나 체스 기물이면 건너뜀
                if ((r1 == r2 && c1 == c2) || board[r2][c2].hasChessPiece)
                  continue;

                // 두 번째 셀도 기물의 공격 범위에 있는지 확인
                if (!canPieceAttack(piece, pieceRow, pieceCol, r2, c2))
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

  print('체스 기물 규칙 검증 통과');
  print('보드 유효성 검증 완료: 유효함');
  return true;
}

// 체스 기물 공격 범위 헬퍼 함수
bool canPieceAttack(ChessPiece piece, int pieceRow, int pieceCol, int targetRow,
    int targetCol) {
  switch (piece) {
    case ChessPiece.knight:
      final rowDiff = (pieceRow - targetRow).abs();
      final colDiff = (pieceCol - targetCol).abs();
      return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

    case ChessPiece.rook:
      return pieceRow == targetRow || pieceCol == targetCol;

    case ChessPiece.bishop:
      final rowDiff = (pieceRow - targetRow).abs();
      final colDiff = (pieceCol - targetCol).abs();
      return rowDiff == colDiff;

    case ChessPiece.queen:
      final rowDiff = (pieceRow - targetRow).abs();
      final colDiff = (pieceCol - targetCol).abs();
      return pieceRow == targetRow ||
          pieceCol == targetCol ||
          rowDiff == colDiff;

    case ChessPiece.king:
      final rowDiff = (pieceRow - targetRow).abs();
      final colDiff = (pieceCol - targetCol).abs();
      return rowDiff <= 1 && colDiff <= 1;
  }
}

// 테스트 실행 메인 함수
void main() {
  print('===== 체스도쿠 생성기 테스트 시작 =====\n');

  final generator = ChessSudokuGenerator();

  // 각 난이도별 테스트 실행
  for (final difficulty in Difficulty.values) {
    print('\n===== 난이도: $difficulty 테스트 =====\n');

    // 체스도쿠 보드 생성
    final board = generator.generateBoard(difficulty);

    // 보드 출력
    print('생성된 체스도쿠 보드:');
    printBoard(board);

    // 체스 기물 개수 확인
    int chessPieceCount = 0;
    for (int row = 0; row < ChessSudokuGenerator.BOARD_SIZE; row++) {
      for (int col = 0; col < ChessSudokuGenerator.BOARD_SIZE; col++) {
        if (board[row][col].hasChessPiece) {
          chessPieceCount++;
        }
      }
    }
    print('총 체스 기물 개수: $chessPieceCount');

    // 보드 유효성 검증
    final isValid = validateBoard(board);
    print('보드 유효성 검증 결과: ${isValid ? "성공" : "실패"}');
  }

  print('\n===== 체스도쿠 생성기 테스트 완료 =====');
}

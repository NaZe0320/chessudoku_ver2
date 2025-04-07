import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

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

  test('체스도쿠 퍼즐 풀이', () async {
    final generator = ChessSudokuGenerator();

    // 퍼즐 생성 시간 측정 시작
    final generationStopwatch = Stopwatch()..start();

    print('체스도쿠 생성 중...');
    final puzzleBoard = await generator.generatePuzzle(Difficulty.medium);

    // 퍼즐 생성 시간 측정 종료
    generationStopwatch.stop();

    print('퍼즐 생성 완료! 생성 시간: ${generationStopwatch.elapsedMilliseconds}ms');
    print('\n=========== 원본 퍼즐 보드 ===========');
    _printBoard(puzzleBoard);

    print('\n풀이 시작...');

    // 퍼즐 복사본 생성 (원본 보존)
    final solutionBoard = _cloneBoard(puzzleBoard);

    // 풀이 시간 측정 시작
    final solvingStopwatch = Stopwatch()..start();

    // 휴리스틱 풀이 알고리즘 적용
    final solver = ChessSudokuSolver(solutionBoard);
    final bool solved = solver.solve();

    // 풀이 시간 측정 종료
    solvingStopwatch.stop();

    // 결과 출력
    print('\n=========== 체스도쿠 풀이 결과 ===========');
    print('풀이 성공 여부: ${solved ? "성공" : "실패"}');
    print('풀이 소요 시간: ${solvingStopwatch.elapsedMilliseconds}ms');
    print('시도한 배치 횟수: ${solver.attempts}회');

    if (solved) {
      print('\n=========== 풀이 결과 보드 ===========');
      _printBoard(solutionBoard);

      // 풀이 검증
      bool isValid = solver.validateSolution();
      print('풀이 유효성: ${isValid ? "유효함" : "유효하지 않음"}');

      expect(solved, true);
      expect(isValid, true);
    }
  });
}

/// 보드 복제 함수
List<List<CellContent>> _cloneBoard(List<List<CellContent>> board) {
  return List.generate(
    board.length,
    (i) => List.generate(
      board[i].length,
      (j) => board[i][j].copyWith(),
    ),
  );
}

/// 보드 출력 함수
void _printBoard(List<List<CellContent>> board) {
  for (int i = 0; i < board.length; i++) {
    String rowStr = '';
    for (int j = 0; j < board[i].length; j++) {
      final cell = board[i][j];
      if (cell.hasChessPiece) {
        final pieceType = cell.chessPiece.toString().split('.').last;
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
}

/// 체스도쿠 퍼즐 풀이기
class ChessSudokuSolver {
  static const int boardSize = 9;
  final List<List<CellContent>> board;
  final Map<String, Set<String>> attackedCells = {};
  final List<Set<int>> rowSets, colSets, boxSets;
  final List<List<Set<int>>> candidates;
  int attempts = 0;

  ChessSudokuSolver(this.board)
      : rowSets = List.generate(boardSize, (_) => <int>{}),
        colSets = List.generate(boardSize, (_) => <int>{}),
        boxSets = List.generate(boardSize, (_) => <int>{}),
        candidates = List.generate(
          boardSize,
          (_) => List.generate(
            boardSize,
            (_) => <int>{},
          ),
        ) {
    // 초기화
    _initialize();
  }

  /// 풀이 시작 전 초기화
  void _initialize() {
    // 기존에 있는 숫자 제약 조건 추가
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j].hasNumber) {
          final num = board[i][j].number;
          final boxIdx = (i ~/ 3) * 3 + (j ~/ 3);

          rowSets[i].add(num!);
          colSets[j].add(num);
          boxSets[boxIdx].add(num);
        }
      }
    }

    // 체스 기물 공격 범위 계산
    _calculateAttackRanges();

    // 각 셀의 후보 숫자 초기화
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (!board[i][j].hasNumber && !board[i][j].hasChessPiece) {
          candidates[i][j] = _getCandidatesForCell(i, j);
        }
      }
    }
  }

  /// 체스 기물 공격 범위 계산
  void _calculateAttackRanges() {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j].hasChessPiece) {
          final ChessPiece piece = board[i][j].chessPiece!;
          final String pieceKey = '$i,$j';

          attackedCells[pieceKey] = _getAttacks(piece, i, j);
        }
      }
    }
  }

  /// 기물 타입별 공격 범위 반환
  Set<String> _getAttacks(ChessPiece type, int row, int col) {
    switch (type) {
      case ChessPiece.knight:
        return _getKnightAttacks(row, col);
      case ChessPiece.bishop:
        return _getBishopAttacks(row, col);
      case ChessPiece.king:
        return _getKingAttacks(row, col);
      case ChessPiece.queen:
        return _getQueenAttacks(row, col);
      case ChessPiece.rook:
        return _getRookAttacks(row, col);
    }
  }

  /// 나이트 공격 범위
  Set<String> _getKnightAttacks(int row, int col) {
    final moves = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];

    return _getValidPositions(row, col, moves);
  }

  /// 킹 공격 범위
  Set<String> _getKingAttacks(int row, int col) {
    final moves = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    return _getValidPositions(row, col, moves);
  }

  /// 유효한 위치 계산 (나이트, 킹 공통)
  Set<String> _getValidPositions(int row, int col, List<List<int>> moves) {
    return moves
        .map((dir) => [row + dir[0], col + dir[1]])
        .where((pos) =>
            pos[0] >= 0 &&
            pos[0] < boardSize &&
            pos[1] >= 0 &&
            pos[1] < boardSize)
        .map((pos) => '${pos[0]},${pos[1]}')
        .toSet();
  }

  /// 비숍 공격 범위
  Set<String> _getBishopAttacks(int row, int col) {
    // 대각선 방향
    final directions = [
      [-1, 1],
      [1, 1],
      [1, -1],
      [-1, -1]
    ];
    return _getSlidingAttacks(row, col, directions);
  }

  /// 룩 공격 범위
  Set<String> _getRookAttacks(int row, int col) {
    // 가로 세로 방향
    final directions = [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0]
    ];
    return _getSlidingAttacks(row, col, directions);
  }

  /// 퀸 공격 범위
  Set<String> _getQueenAttacks(int row, int col) {
    // 비숍 + 룩 공격 범위
    return _getBishopAttacks(row, col).union(_getRookAttacks(row, col));
  }

  /// 슬라이딩 기물(비숍, 룩, 퀸)용 공격 범위 계산
  Set<String> _getSlidingAttacks(int row, int col, List<List<int>> directions) {
    Set<String> attacks = <String>{};

    for (final dir in directions) {
      int r = row + dir[0];
      int c = col + dir[1];

      while (r >= 0 && r < boardSize && c >= 0 && c < boardSize) {
        attacks.add('$r,$c');
        // 다른 기물에 막히면 중단
        if (board[r][c].hasChessPiece) break;
        r += dir[0];
        c += dir[1];
      }
    }

    return attacks;
  }

  /// 특정 셀에 대한 후보 숫자 계산
  Set<int> _getCandidatesForCell(int row, int col) {
    final Set<int> result = Set<int>.from(List.generate(9, (i) => i + 1));
    final int boxIdx = (row ~/ 3) * 3 + (col ~/ 3);

    // 행, 열, 박스 제약 적용
    for (final int num in rowSets[row]) {
      result.remove(num);
    }

    for (final int num in colSets[col]) {
      result.remove(num);
    }

    for (final int num in boxSets[boxIdx]) {
      result.remove(num);
    }

    // 체스 기물 제약 적용
    final cellKey = '$row,$col';

    for (final entry in attackedCells.entries) {
      if (entry.value.contains(cellKey)) {
        for (final attackedCell in entry.value) {
          if (attackedCell == cellKey) continue;

          final coords = attackedCell.split(',');
          final int r = int.parse(coords[0]);
          final int c = int.parse(coords[1]);

          if (board[r][c].hasNumber) {
            result.remove(board[r][c].number!);
          }
        }
      }
    }

    return result;
  }

  /// 가장 후보가 적은 빈 셀 찾기 (MRV 휴리스틱)
  List<int>? _findNextCell() {
    int minCandidates = 10;
    List<int>? bestCell;

    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (!board[i][j].hasNumber && !board[i][j].hasChessPiece) {
          int candidateCount = candidates[i][j].length;

          if (candidateCount < minCandidates) {
            minCandidates = candidateCount;
            bestCell = <int>[i, j];

            if (minCandidates == 1) return bestCell; // 최적의 선택
          }
        }
      }
    }

    return bestCell;
  }

  /// 백트래킹 알고리즘으로 풀이
  bool solve() {
    attempts++;

    // 다음 채울 셀 찾기
    final nextCell = _findNextCell();
    if (nextCell == null) return true; // 모든 셀이 채워짐

    final int row = nextCell[0];
    final int col = nextCell[1];

    // 후보 숫자 정렬 (가장 제약이 많은 값부터 시도)
    final candidateList = candidates[row][col].toList();

    for (final num in candidateList) {
      // 숫자 배치
      board[row][col] = CellContent(number: num, isInitial: false);

      // 제약 전파
      final boxIdx = (row ~/ 3) * 3 + (col ~/ 3);
      rowSets[row].add(num);
      colSets[col].add(num);
      boxSets[boxIdx].add(num);

      // 후보 목록 업데이트
      Map<String, Set<int>> savedCandidates = {};
      bool invalid = false;

      // 영향받는 셀들의 후보 목록 업데이트
      for (int i = 0; i < boardSize; i++) {
        // 같은 행
        if (i != col &&
            !board[row][i].hasNumber &&
            !board[row][i].hasChessPiece) {
          savedCandidates['$row,$i'] = Set<int>.from(candidates[row][i]);
          candidates[row][i].remove(num);
          if (candidates[row][i].isEmpty) {
            invalid = true;
            break;
          }
        }

        // 같은 열
        if (i != row &&
            !board[i][col].hasNumber &&
            !board[i][col].hasChessPiece) {
          savedCandidates['$i,$col'] = Set<int>.from(candidates[i][col]);
          candidates[i][col].remove(num);
          if (candidates[i][col].isEmpty) {
            invalid = true;
            break;
          }
        }

        // 같은 박스
        final boxRow = 3 * (boxIdx ~/ 3) + (i ~/ 3);
        final boxCol = 3 * (boxIdx % 3) + (i % 3);
        if ((boxRow != row || boxCol != col) &&
            !board[boxRow][boxCol].hasNumber &&
            !board[boxRow][boxCol].hasChessPiece) {
          savedCandidates['$boxRow,$boxCol'] =
              Set<int>.from(candidates[boxRow][boxCol]);
          candidates[boxRow][boxCol].remove(num);
          if (candidates[boxRow][boxCol].isEmpty) {
            invalid = true;
            break;
          }
        }
      }

      // 체스 기물 제약 처리
      final cellKey = '$row,$col';
      for (final entry in attackedCells.entries) {
        if (entry.value.contains(cellKey)) {
          for (final attackedCell in entry.value) {
            if (attackedCell == cellKey) continue;

            final coords = attackedCell.split(',');
            final r = int.parse(coords[0]);
            final c = int.parse(coords[1]);

            if (!board[r][c].hasNumber && !board[r][c].hasChessPiece) {
              savedCandidates[attackedCell] = Set<int>.from(candidates[r][c]);
              candidates[r][c].remove(num);
              if (candidates[r][c].isEmpty) {
                invalid = true;
                break;
              }
            }
          }
          if (invalid) break;
        }
      }

      // 유효한 배치면 계속 진행
      if (!invalid && solve()) {
        return true;
      }

      // 백트래킹
      board[row][col] = const CellContent(isInitial: false);
      rowSets[row].remove(num);
      colSets[col].remove(num);
      boxSets[boxIdx].remove(num);

      // 후보 목록 복원
      savedCandidates.forEach((pos, savedSet) {
        final coords = pos.split(',');
        final r = int.parse(coords[0]);
        final c = int.parse(coords[1]);
        candidates[r][c] = savedSet;
      });
    }

    return false;
  }

  /// 풀이 결과 유효성 검증
  bool validateSolution() {
    // 모든 셀이 채워졌는지 확인
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (!board[i][j].hasNumber && !board[i][j].hasChessPiece) {
          return false;
        }
      }
    }

    // 행, 열, 박스 규칙 검증
    for (int i = 0; i < boardSize; i++) {
      Set<int> rowNums = {};
      Set<int> colNums = {};
      Set<int> boxNums = {};

      for (int j = 0; j < boardSize; j++) {
        // 행 검증
        if (board[i][j].hasNumber) {
          final int cellNumber = board[i][j].number!;
          if (rowNums.contains(cellNumber)) {
            return false;
          }
          rowNums.add(cellNumber);
        }

        // 열 검증
        if (board[j][i].hasNumber) {
          final int cellNumber = board[j][i].number!;
          if (colNums.contains(cellNumber)) {
            return false;
          }
          colNums.add(cellNumber);
        }

        // 3x3 박스 검증
        final int boxRow = 3 * (i ~/ 3) + (j ~/ 3);
        final int boxCol = 3 * (i % 3) + (j % 3);

        if (board[boxRow][boxCol].hasNumber) {
          final int cellNumber = board[boxRow][boxCol].number!;
          if (boxNums.contains(cellNumber)) {
            return false;
          }
          boxNums.add(cellNumber);
        }
      }
    }

    // 체스 기물 규칙 검증
    for (final entry in attackedCells.entries) {
      for (final attackedCell in entry.value) {
        final coords = attackedCell.split(',');
        final int r = int.parse(coords[0]);
        final int c = int.parse(coords[1]);

        if (board[r][c].hasNumber) {
          final int cellNumber = board[r][c].number!;
          // 같은 공격 범위 내 모든 셀 확인
          for (final otherCell in entry.value) {
            if (otherCell == attackedCell) continue;

            final otherCoords = otherCell.split(',');
            final int or = int.parse(otherCoords[0]);
            final int oc = int.parse(otherCoords[1]);

            if (board[or][oc].hasNumber && board[or][oc].number == cellNumber) {
              return false;
            }
          }
        }
      }
    }

    return true;
  }
}

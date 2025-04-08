import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'dart:math';

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

    // 초기 힌트 숫자 개수 계산
    int initialHints = 0;
    int chessPieces = 0;
    for (final row in puzzleBoard) {
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
    print('퍼즐 생성 완료! 생성 시간: ${generationStopwatch.elapsedMilliseconds}ms');
    print('\n=========== 원본 퍼즐 보드 ===========');
    _printBoard(puzzleBoard);

    // 10번 풀이 반복을 위한 설정
    const int solveAttempts = 100;
    final List<List<List<CellContent>>> successfulBoards = []; // 성공한 보드만 저장
    final List<int> successTimes = []; // 성공한 경우의 소요 시간
    final List<int> successAttemptCounts = []; // 성공한 경우의 시도 횟수
    int successCount = 0;
    int failCount = 0;

    print('\n=========== 퍼즐 풀이 100회 반복 (랜덤 순서 사용) ===========');

    for (int i = 0; i < solveAttempts; i++) {
      print('\n[$i번째 풀이 시작]');

      // 퍼즐 복사본 생성 (원본 보존)
      final solutionBoard = _cloneBoard(puzzleBoard);

      // 풀이 시간 측정 시작
      final solvingStopwatch = Stopwatch()..start();

      // 휴리스틱 풀이 알고리즘 적용 - 각 인스턴스마다 다른 랜덤 시드 사용
      final solver = ChessSudokuSolver(solutionBoard,
          randomSeed: DateTime.now().millisecondsSinceEpoch + i,
          useRandomOrder: true // 랜덤 순서 사용 활성화
          );
      final bool solved = solver.solve();

      // 풀이 시간 측정 종료
      solvingStopwatch.stop();

      // 간략한 결과 출력
      print(
          '$i번째 풀이 결과: ${solved ? "성공" : "실패"} / ${solvingStopwatch.elapsedMilliseconds}ms / ${solver.attempts}회"}');
      // 성공한 경우만 저장
      if (solved) {
        successCount++;
        successfulBoards.add(_cloneBoard(solutionBoard));
        successTimes.add(solvingStopwatch.elapsedMilliseconds);
        successAttemptCounts.add(solver.attempts);
      } else {
        failCount++;
        print('$i번째 풀이 실패 원인: ${solver.analyzeFailure()}');
      }
    }

    // 결과 분석 및 요약
    print('\n=========== 10회 풀이 결과 요약 ===========');
    print('성공 횟수: $successCount / $solveAttempts');
    print('실패 횟수: $failCount / $solveAttempts');

    if (successCount > 0) {
      final avgSuccessTime =
          successTimes.fold(0, (sum, time) => sum + time) / successCount;
      print('평균 성공 소요 시간: ${avgSuccessTime.toStringAsFixed(2)}ms');

      final avgAttempts =
          successAttemptCounts.fold(0, (sum, count) => sum + count) /
              successCount;
      print('평균 성공 시도 횟수: ${avgAttempts.toStringAsFixed(2)}회');
    }

    // 성공한 보드들 간의 일관성 검사 (성공한 보드만 비교)
    if (successCount >= 2) {
      print('\n=========== 풀이 결과 일관성 검사 (성공한 경우만) ===========');

      // 서로 다른 해를 저장할 리스트
      List<List<List<CellContent>>> uniqueSolutions = [successfulBoards[0]];

      // 첫 번째 이후의 모든 해를 비교하여 새로운 해 찾기
      for (int i = 1; i < successfulBoards.length; i++) {
        bool isNewSolution = true;
        for (final existingSolution in uniqueSolutions) {
          if (_boardsEqual(existingSolution, successfulBoards[i])) {
            isNewSolution = false;
            break;
          }
        }
        if (isNewSolution) {
          uniqueSolutions.add(successfulBoards[i]);
        }
      }

      if (uniqueSolutions.length == 1) {
        print('모든 성공한 풀이 결과가 동일합니다 => 유일해로 판단됩니다.');
      } else {
        print(
            '성공한 풀이 결과들이 서로 다릅니다 => ${uniqueSolutions.length}개의 서로 다른 해가 발견되었습니다!');
        print('차이점 분석:');

        // 첫 번째 해를 기준으로 다른 해들과 비교
        final baseBoard = uniqueSolutions[0];
        for (int i = 1; i < uniqueSolutions.length; i++) {
          final diffBoard = uniqueSolutions[i];
          final diffCount = _countBoardDifferences(baseBoard, diffBoard);

          print('\n$i번째 해와의 차이:');
          print('기준 해와 $i번째 해의 차이: $diffCount개 셀');
        }
      }
    } else if (successCount == 1) {
      print('\n단 한 번만 성공했으므로 유일해 여부를 확정할 수 없습니다.');
    } else {
      print('\n모든 시도가 실패했으므로 풀이 불가능한 퍼즐입니다.');
    }

    // 첫 번째 성공한 보드 결과 출력
    if (successCount > 0) {
      print('\n=========== 첫 번째 성공 풀이 결과 보드 ===========');
      _printBoard(successfulBoards[0]);

      // 풀이 검증
      final firstSuccessSolver = ChessSudokuSolver(successfulBoards[0]);
      bool isValid = firstSuccessSolver.validateSolution();
      print('풀이 유효성: ${isValid ? "유효함" : "유효하지 않음"}');

      expect(isValid, true);
    } else if (failCount > 0) {
      // 모든 시도가 실패한 경우 원인 분석
      print('\n=========== 모든 풀이 실패 - 원인 분석 필요 ===========');
      print('체스도쿠 퍼즐이 해결 불가능하거나 알고리즘의 한계로 해결하지 못했습니다.');
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

  // 풀이 실패 분석용 데이터
  String failureReason = '';
  List<int>? lastFailedCell;
  Set<int>? lastCandidates;

  // 랜덤 순서로 후보 숫자 선택을 위한 난수 생성기
  final Random _random;
  final bool _useRandomOrder;

  // 생성자 수정 - 랜덤 시드와 랜덤 순서 사용 여부 옵션 추가
  ChessSudokuSolver(this.board, {int? randomSeed, bool useRandomOrder = false})
      : rowSets = List.generate(boardSize, (_) => <int>{}),
        colSets = List.generate(boardSize, (_) => <int>{}),
        boxSets = List.generate(boardSize, (_) => <int>{}),
        candidates = List.generate(
          boardSize,
          (_) => List.generate(
            boardSize,
            (_) => <int>{},
          ),
        ),
        // 시드 값이 제공되면 해당 시드로 Random 인스턴스 생성, 아니면 현재 시간을 시드로 사용
        _random = Random(randomSeed ?? DateTime.now().millisecondsSinceEpoch),
        _useRandomOrder = useRandomOrder {
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

    // 후보가 없는 경우 실패 기록
    if (candidates[row][col].isEmpty) {
      lastFailedCell = [row, col];
      failureReason = '셀 ($row,$col)에 배치할 수 있는 후보 숫자가 없습니다.';
      return false;
    }

    // 후보 숫자 정렬 (가장 제약이 많은 값부터 시도)
    final candidateList = candidates[row][col].toList();

    // 랜덤 순서 사용 옵션이 켜져 있으면 후보 숫자를 랜덤하게 섞음
    if (_useRandomOrder) {
      candidateList.shuffle(_random);
    }

    lastCandidates = Set<int>.from(candidateList);

    if (candidateList.isEmpty) {
      lastFailedCell = [row, col];
      failureReason = '셀 ($row,$col)에 배치할 수 있는 후보 숫자가 없습니다.';
      return false;
    }

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

  /// 풀이 실패 원인 분석
  String analyzeFailure() {
    if (failureReason.isNotEmpty) {
      return failureReason;
    }

    // 최소 후보 개수 찾기
    int minCandidates = 10;
    List<int>? problematicCell;

    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (!board[i][j].hasNumber && !board[i][j].hasChessPiece) {
          if (candidates[i][j].isEmpty) {
            return '셀 ($i,$j)에 배치할 수 있는 후보 숫자가 없습니다.';
          }

          if (candidates[i][j].length < minCandidates) {
            minCandidates = candidates[i][j].length;
            problematicCell = [i, j];
          }
        }
      }
    }

    if (problematicCell != null) {
      final row = problematicCell[0];
      final col = problematicCell[1];
      final availableCandidates = candidates[row][col].join(', ');

      return '가장 제약이 많은 셀 ($row,$col)의 후보: [$availableCandidates]입니다. '
          '모든 후보 배치 시 다른 셀에서 모순이 발생합니다.';
    }

    if (lastFailedCell != null) {
      final row = lastFailedCell![0];
      final col = lastFailedCell![1];
      final candidatesStr = lastCandidates?.join(', ') ?? '없음';

      return '셀 ($row,$col)에서 후보 [$candidatesStr]를 모두 시도했으나 모순이 발생했습니다.';
    }

    return '퍼즐이 잘못 구성되었거나 규칙에 따른 해가 존재하지 않습니다.';
  }
}

// 풀이 실패 분석용 헬퍼 함수들
List<int> _getRowNumbers(List<List<CellContent>> board, int row) {
  final numbers = <int>[];

  for (int j = 0; j < 9; j++) {
    if (board[row][j].hasNumber) {
      numbers.add(board[row][j].number!);
    }
  }

  return numbers;
}

List<int> _getColNumbers(List<List<CellContent>> board, int col) {
  final numbers = <int>[];

  for (int i = 0; i < 9; i++) {
    if (board[i][col].hasNumber) {
      numbers.add(board[i][col].number!);
    }
  }

  return numbers;
}

List<int> _getBoxNumbers(List<List<CellContent>> board, int row, int col) {
  final numbers = <int>[];
  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[boxRow + i][boxCol + j].hasNumber) {
        numbers.add(board[boxRow + i][boxCol + j].number!);
      }
    }
  }

  return numbers;
}

// 두 보드가 완전히 동일한지 확인하는 함수
bool _boardsEqual(
    List<List<CellContent>> board1, List<List<CellContent>> board2) {
  if (board1.length != board2.length) return false;

  for (int i = 0; i < board1.length; i++) {
    if (board1[i].length != board2[i].length) return false;

    for (int j = 0; j < board1[i].length; j++) {
      if (!_cellsEqual(board1[i][j], board2[i][j])) {
        return false;
      }
    }
  }

  return true;
}

// 두 셀이 완전히 동일한지 확인하는 함수
bool _cellsEqual(CellContent cell1, CellContent cell2) {
  // 체스 기물 확인
  if (cell1.hasChessPiece != cell2.hasChessPiece) return false;
  if (cell1.hasChessPiece &&
      cell2.hasChessPiece &&
      cell1.chessPiece != cell2.chessPiece) return false;

  // 숫자 확인
  if (cell1.hasNumber != cell2.hasNumber) return false;
  if (cell1.hasNumber && cell2.hasNumber && cell1.number != cell2.number)
    return false;

  return true;
}

// 셀 내용을 문자열로 변환
String _cellToString(CellContent cell) {
  if (cell.hasChessPiece) {
    return cell.chessPiece.toString().split('.').last;
  } else if (cell.hasNumber) {
    return '${cell.number}';
  } else {
    return '빈칸';
  }
}

// 보드 간 차이 개수 계산
int _countBoardDifferences(
    List<List<CellContent>> board1, List<List<CellContent>> board2) {
  int diffCount = 0;

  for (int i = 0; i < board1.length; i++) {
    for (int j = 0; j < board1[i].length; j++) {
      if (!_cellsEqual(board1[i][j], board2[i][j])) {
        diffCount++;
      }
    }
  }

  return diffCount;
}

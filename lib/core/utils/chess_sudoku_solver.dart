import 'dart:math';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/core/utils/chess_sudoku_validator.dart';

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
    Set<String> attacks = <String>{};

    // 보드의 모든 셀에 대해 공격 가능 여부 확인
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (ChessSudokuValidator.canPieceAttack(type, row, col, r, c)) {
          attacks.add('$r,$c');
          // 다른 기물에 막히면 해당 방향 중단
          if (board[r][c].hasChessPiece) {
            // 슬라이딩 기물(비숍, 룩, 퀸)의 경우에만 방향 차단 적용
            if (type == ChessPiece.bishop || type == ChessPiece.rook || type == ChessPiece.queen) {
              // 방향 벡터 계산
              final rowDir = r - row != 0 ? (r - row) ~/ (r - row).abs() : 0;
              final colDir = c - col != 0 ? (c - col) ~/ (c - col).abs() : 0;
              // 같은 방향의 다음 셀들은 제외
              for (int i = r + rowDir, j = c + colDir;
                  i >= 0 && i < boardSize && j >= 0 && j < boardSize;
                  i += rowDir, j += colDir) {
                attacks.remove('$i,$j');
              }
            }
          }
        }
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

    // 최대 시도 횟수 제한
    if (attempts > 10000) {
      return false;
    }

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
        if (i != col && !board[row][i].hasNumber && !board[row][i].hasChessPiece) {
          savedCandidates['$row,$i'] = Set<int>.from(candidates[row][i]);
          candidates[row][i].remove(num);
          if (candidates[row][i].isEmpty) {
            invalid = true;
            break;
          }
        }

        // 같은 열
        if (i != row && !board[i][col].hasNumber && !board[i][col].hasChessPiece) {
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
          savedCandidates['$boxRow,$boxCol'] = Set<int>.from(candidates[boxRow][boxCol]);
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

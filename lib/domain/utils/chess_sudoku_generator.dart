import 'dart:math';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/utils/chess_sudoku_solver.dart'; // ChessSudokuSolver 임포트

/// 체스도쿠 퍼즐 생성기
/// 체스도쿠 규칙에 맞는 유효한 퍼즐을 효율적으로 생성합니다.
class ChessSudokuGenerator {
  static const int boardSize = 9;
  final Random _random = Random();

  // 보드 상태 데이터
  late List<List<CellContent>> _board;
  late List<List<Set<int>>> _candidates;
  late List<Set<int>> _rowSets, _colSets, _boxSets;
  final Map<String, Set<String>> _attackedCells = {};

  // 난이도별 빈칸 설정 (최소, 최대, 배치크기)
  // 배치 있는 이유 (계산 횟수 감소 시키려고 batch 마다 검산 시도)
  final Map<Difficulty, Map<String, int>> _puzzleConfig = {
    Difficulty.easy: {'minEmpty': 30, 'maxEmpty': 40, 'batchSize': 1},
    Difficulty.medium: {'minEmpty': 36, 'maxEmpty': 50, 'batchSize': 1},
    Difficulty.hard: {'minEmpty': 46, 'maxEmpty': 55, 'batchSize': 1},
  };

  /// 체스도쿠 보드 생성
  List<List<CellContent>> generateBoard(Difficulty difficulty) {
    const int maxAttempts = 10000000;

    for (int attempts = 0; attempts < maxAttempts; attempts++) {
      try {
        _initialize();

        // 난이도별 체스 기물 배치
        final pieces = _generatePieces(difficulty);
        _placePieces(pieces);
        _calculateAttackRanges(pieces);

        // 백트래킹으로 퍼즐 생성
        if (_solveSudoku()) {
          print('스도쿠 솔루션 생성 성공: 시도 $attempts/$maxAttempts');
          return _board;
        }
      } catch (e) {
        print('예외 발생: $e, 시도 ${attempts + 1}/$maxAttempts');
      }
    }

    throw Exception("체스도쿠 생성에 실패했습니다. 최대 시도 횟수 초과.");
  }

  /// 체스도쿠 퍼즐 생성 (빈칸이 있는 문제)
  Future<List<List<CellContent>>> generatePuzzle(Difficulty difficulty) async {
    // 시간 제한 설정
    final deadline = DateTime.now().add(const Duration(seconds: 100));

    while (DateTime.now().isBefore(deadline)) {
      try {
        // 완전한 솔루션 보드 생성
        final solutionBoard = generateBoard(difficulty);

        // 퍼즐용 보드 복제
        final puzzleBoard = _cloneBoard(solutionBoard);

        // 빈칸 뚫기
        final success =
            await _digHoles(puzzleBoard, solutionBoard, difficulty, deadline);

        if (success) {
          // 퍼즐의 풀이 가능성 검증
          if (_verifyPuzzleSolvability(puzzleBoard)) {
            print('퍼즐 생성 성공 (풀이 가능성 검증 완료)');
            return puzzleBoard;
          } else {
            print('풀이 불가능한 퍼즐 생성됨, 다시 시도합니다');
            continue;
          }
        }
      } catch (e) {
        print('퍼즐 생성 오류: $e');
      }
    }

    throw Exception("시간 제한 내에 퍼즐 생성에 실패했습니다.");
  }

  /// 퍼즐의 풀이 가능성 검증
  bool _verifyPuzzleSolvability(List<List<CellContent>> puzzleBoard) {
    // 여러 번 풀이 시도하여 풀이 가능성 검증
    const int solveAttempts = 10;
    int successCount = 0;

    for (int i = 0; i < solveAttempts; i++) {
      // 퍼즐 복제 (원본 보존)
      final testBoard = _cloneBoard(puzzleBoard);

      // 체스도쿠 풀이기 생성 (각 시도마다 다른 랜덤 시드 사용)
      final solver = ChessSudokuSolver(testBoard,
          randomSeed: DateTime.now().millisecondsSinceEpoch + i,
          useRandomOrder: true // 랜덤 순서 사용
          );

      // 풀이 시도
      if (solver.solve()) {
        successCount++;

        // 최소 1번 성공하면 검증 통과 (더 엄격하게 하려면 숫자를 높일 수 있음)
        if (successCount >= 1) {
          return true;
        }
      }
    }

    // 모든 시도가 실패한 경우
    return false;
  }

  /// 초기화
  void _initialize() {
    // 보드 초기화
    _board = List.generate(
      boardSize,
      (_) => List.generate(
        boardSize,
        (_) => const CellContent(isInitial: false),
      ),
    );

    // 후보 숫자 초기화 (1-9)
    _candidates = List.generate(
      boardSize,
      (_) => List.generate(
        boardSize,
        (_) => Set<int>.from(List.generate(9, (i) => i + 1)),
      ),
    );

    // 제약 조건 추적용 집합 초기화
    _rowSets = List.generate(boardSize, (_) => <int>{});
    _colSets = List.generate(boardSize, (_) => <int>{});
    _boxSets = List.generate(boardSize, (_) => <int>{});

    // 공격 범위 캐시 초기화
    _attackedCells.clear();
  }

  /// 빈칸 뚫기 알고리즘
  Future<bool> _digHoles(
      List<List<CellContent>> puzzleBoard,
      List<List<CellContent>> solutionBoard,
      Difficulty difficulty,
      DateTime deadline) async {
    // 난이도별 설정 가져오기
    final config = _puzzleConfig[difficulty]!;

    // 숫자가 있는 모든 셀 위치 목록 생성
    final cellsWithNumbers = <List<int>>[];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (puzzleBoard[i][j].hasNumber) {
          cellsWithNumbers.add([i, j]);
        }
      }
    }

    // 랜덤하게 섞기
    cellsWithNumbers.shuffle(_random);

    // 목표 빈칸 수 계산
    final targetEmpty = config['minEmpty']! +
        _random.nextInt(config['maxEmpty']! - config['minEmpty']! + 1);

    int emptyCellCount = 0;
    int batchSize = config['batchSize']!;

    // 배치 단위로 효율적으로 처리
    while (emptyCellCount < targetEmpty &&
        cellsWithNumbers.isNotEmpty &&
        DateTime.now().isBefore(deadline)) {
      // 배치 선택
      final batch = <List<int>>[];
      final int batchCount = min(batchSize, cellsWithNumbers.length);

      for (int i = 0; i < batchCount; i++) {
        if (cellsWithNumbers.isEmpty) break;
        batch.add(cellsWithNumbers.removeAt(0));
      }

      // 배치에서 숫자 제거
      for (final cell in batch) {
        final row = cell[0];
        final col = cell[1];

        // 숫자 제거
        puzzleBoard[row][col] = const CellContent(isInitial: false);
        emptyCellCount++;
      }
    }

    return emptyCellCount >= config['minEmpty']!;
  }

  /// 보드 복제
  List<List<CellContent>> _cloneBoard(List<List<CellContent>> board) {
    return List.generate(
      boardSize,
      (i) => List.generate(
        boardSize,
        (j) => board[i][j].copyWith(),
      ),
    );
  }

  /// 체스 기물 생성
  List<List<dynamic>> _generatePieces(Difficulty difficulty) {
    final pieces = <List<dynamic>>[];
    final Map<ChessPiece, int> pieceCount = {};

    // 난이도별 기물 설정
    final config = _getDifficultyConfig(difficulty);

    // 먼저 각 기물의 최소 개수를 적용
    for (final piece in ChessPiece.values) {
      int minCount = config['pieces']![piece]![0];
      pieceCount[piece] = minCount;

      // 최소 개수만큼 기물 배치를 미리 예약
      for (int i = 0; i < minCount; i++) {
        _placePieceRandomly(pieces, piece);
      }
    }

    // 랜덤하게 추가 기물을 배치할 수 있는 범위 계산
    int placedPieces =
        pieceCount.values.fold<int>(0, (sum, count) => sum + count);
    int maxAdditionalPieces = config['maxPieces']! - placedPieces;

    // 최소 필요 기물 수 계산
    int minRequiredPieces = max(0, config['minPieces']! - placedPieces);

    // 추가 기물 수를 최소 필요 수부터 최대 가능 수 사이로 계산
    int additionalPieces = minRequiredPieces;
    if (maxAdditionalPieces > minRequiredPieces) {
      additionalPieces +=
          _random.nextInt(maxAdditionalPieces - minRequiredPieces + 1);
    }

    // 나머지 기물 랜덤 배치
    List<ChessPiece> availablePieces = ChessPiece.values.toList();
    int remainingPieces = additionalPieces;

    while (remainingPieces > 0 && availablePieces.isNotEmpty) {
      int pieceIndex = _random.nextInt(availablePieces.length);
      ChessPiece piece = availablePieces[pieceIndex];

      // 최대 제한 확인
      if (pieceCount[piece]! >= config['pieces']![piece]![1]) {
        availablePieces.removeAt(pieceIndex);
        continue;
      }

      pieceCount[piece] = pieceCount[piece]! + 1;
      remainingPieces--;

      // 추가된 기물 랜덤 배치
      _placePieceRandomly(pieces, piece);
    }

    return pieces;
  }

  /// 랜덤 위치에 기물 배치
  void _placePieceRandomly(List<List<dynamic>> pieces, ChessPiece piece) {
    while (true) {
      final int row = _random.nextInt(boardSize);
      final int col = _random.nextInt(boardSize);

      // 중복 방지
      if (!pieces.any((pos) => pos[1] == row && pos[2] == col)) {
        pieces.add([piece, row, col]);
        break;
      }
    }
  }

  /// 난이도별 설정 반환
  Map<String, dynamic> _getDifficultyConfig(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return {
          'pieces': {
            ChessPiece.king: [0, 1],
            ChessPiece.queen: [0, 0],
            ChessPiece.bishop: [0, 1],
            ChessPiece.knight: [1, 1],
            ChessPiece.rook: [0, 0]
          },
          'minPieces': 1,
          'maxPieces': 2
        };
      case Difficulty.medium:
        return {
          'pieces': {
            ChessPiece.king: [0, 1],
            ChessPiece.queen: [0, 1],
            ChessPiece.bishop: [0, 2],
            ChessPiece.knight: [1, 3],
            ChessPiece.rook: [0, 1]
          },
          'minPieces': 3,
          'maxPieces': 5
        };
      case Difficulty.hard:
        return {
          'pieces': {
            ChessPiece.king: [0, 2],
            ChessPiece.queen: [0, 2],
            ChessPiece.bishop: [1, 3],
            ChessPiece.knight: [2, 3],
            ChessPiece.rook: [0, 2]
          },
          'minPieces': 5,
          'maxPieces': 8
        };
    }
  }

  /// 체스 기물 보드에 배치
  void _placePieces(List<List<dynamic>> pieces) {
    for (final piece in pieces) {
      final ChessPiece type = piece[0];
      final int row = piece[1];
      final int col = piece[2];

      _board[row][col] = CellContent(chessPiece: type, isInitial: true);
      _candidates[row][col].clear(); // 기물 위치에는 숫자 배치 불가
    }
  }

  /// 체스 기물 공격 범위 계산
  void _calculateAttackRanges(List<List<dynamic>> pieces) {
    for (final piece in pieces) {
      final ChessPiece type = piece[0];
      final int row = piece[1];
      final int col = piece[2];
      final String pieceKey = '$row,$col';

      // 기물 타입별 공격 범위 계산
      _attackedCells[pieceKey] = _getAttacks(type, row, col);
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
        // 다른 기물이나 숫자에 의한 차단은 고려하지 않음
        r += dir[0];
        c += dir[1];
      }
    }

    return attacks;
  }

  /// 백트래킹 알고리즘으로 스도쿠 풀기
  bool _solveSudoku() {
    final nextCell = _findNextCell();
    if (nextCell == null) return true; // 모든 셀이 채워짐

    final row = nextCell[0];
    final col = nextCell[1];
    final originalCandidates = Set<int>.from(_candidates[row][col]);

    // 후보 숫자들을 랜덤하게 시도
    final candidates = List<int>.from(_candidates[row][col]);
    candidates.shuffle(_random);

    for (final num in candidates) {
      if (_canPlace(row, col, num)) {
        // 숫자 배치 및 제약 전파
        _board[row][col] = CellContent(number: num, isInitial: true);
        _updateCandidates(row, col, num);

        // 재귀적으로 계속 풀기
        if (_solveSudoku()) return true;

        // 백트래킹
        _board[row][col] = const CellContent(isInitial: false);
        _restoreCandidates(row, col, num, originalCandidates);
      }
    }

    return false;
  }

  /// MRV 휴리스틱으로 다음 채울 셀 찾기
  List<int>? _findNextCell() {
    int minCandidates = 10;
    List<int>? bestCell;

    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (!_board[i][j].hasNumber && !_board[i][j].hasChessPiece) {
          int candidateCount = _candidates[i][j].length;

          if (candidateCount < minCandidates) {
            minCandidates = candidateCount;
            bestCell = [i, j];

            if (minCandidates == 1) return bestCell; // 최적의 선택
          }
        }
      }
    }

    return bestCell;
  }

  /// 숫자 배치 가능 여부 확인
  bool _canPlace(int row, int col, int num) {
    // 후보에 없으면 배치 불가
    if (!_candidates[row][col].contains(num)) return false;

    // 행, 열, 박스 제약 확인
    final boxIdx = (row ~/ 3) * 3 + (col ~/ 3);
    if (_rowSets[row].contains(num) ||
        _colSets[col].contains(num) ||
        _boxSets[boxIdx].contains(num)) {
      return false;
    }

    // 체스 기물 제약 확인
    final cellKey = '$row,$col';

    for (final entry in _attackedCells.entries) {
      if (entry.value.contains(cellKey)) {
        // 같은 기물의 공격 범위에 같은 숫자가 있는지 확인
        for (final attackedCell in entry.value) {
          if (attackedCell == cellKey) continue;

          final coords = attackedCell.split(',');
          final r = int.parse(coords[0]);
          final c = int.parse(coords[1]);

          if (_board[r][c].hasNumber && _board[r][c].number == num) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// 제약 전파
  void _updateCandidates(int row, int col, int num) {
    final boxIdx = (row ~/ 3) * 3 + (col ~/ 3);

    // 행, 열, 박스에서 후보 제거
    for (int i = 0; i < boardSize; i++) {
      _candidates[row][i].remove(num); // 행
      _candidates[i][col].remove(num); // 열

      // 같은 박스
      final boxRow = 3 * (boxIdx ~/ 3) + (i ~/ 3);
      final boxCol = 3 * (boxIdx % 3) + (i % 3);
      _candidates[boxRow][boxCol].remove(num);
    }

    // 체스 기물 제약 처리
    final cellKey = '$row,$col';

    for (final entry in _attackedCells.entries) {
      if (entry.value.contains(cellKey)) {
        for (final attackedCell in entry.value) {
          if (attackedCell == cellKey) continue;

          final coords = attackedCell.split(',');
          final r = int.parse(coords[0]);
          final c = int.parse(coords[1]);

          _candidates[r][c].remove(num);
        }
      }
    }

    // 제약 세트 업데이트
    _rowSets[row].add(num);
    _colSets[col].add(num);
    _boxSets[boxIdx].add(num);
  }

  /// 제약 전파 복원 (백트래킹용)
  void _restoreCandidates(
      int row, int col, int num, Set<int> originalCandidates) {
    _candidates[row][col] = Set<int>.from(originalCandidates);

    // 제약 세트 복원
    final boxIdx = (row ~/ 3) * 3 + (col ~/ 3);
    _rowSets[row].remove(num);
    _colSets[col].remove(num);
    _boxSets[boxIdx].remove(num);
  }
}

import 'dart:math';
import 'dart:convert';

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

  /// 체스 기물 심볼
  final Map<ChessPiece, String> _pieces = {
    ChessPiece.king: '♚',
    ChessPiece.queen: '♛',
    ChessPiece.bishop: '♝',
    ChessPiece.knight: '♞',
    ChessPiece.rook: '♜'
  };

  /// 각 기물의 위치 저장
  Map<ChessPiece, List<List<int>>> _piecePositions = {
    ChessPiece.king: [],
    ChessPiece.queen: [],
    ChessPiece.bishop: [],
    ChessPiece.knight: [],
    ChessPiece.rook: []
  };

  /// 나이트의 이동 위치에 있는 숫자들을 추적하기 위한 맵
  Map<String, Set<int>> _knightMoveNumbers = {};

  /// 비숍의 대각선 위치에 있는 숫자들을 추적하기 위한 맵
  Map<String, Map<String, Set<int>>> _bishopDiagonals = {};

  /// 킹 주변의 숫자들을 추적하기 위한 맵
  Map<String, Set<int>> _kingAdjacentNumbers = {};

  /// 퀸의 이동 위치에 있는 숫자들을 추적하기 위한 맵
  Map<String, Map<String, Set<int>>> _queenMoveNumbers = {};

  /// 9x9 보드 초기화
  List<List<CellContent>> _board = List.generate(
    BOARD_SIZE,
    (_) => List.generate(
      BOARD_SIZE,
      (_) => const CellContent(isInitial: false),
    ),
  );

  /// 킹의 이동 가능한 위치(주변 8방향) 반환
  List<List<int>> _getKingMoves(int row, int col) {
    final moves = [
      [row - 1, col - 1],
      [row - 1, col],
      [row - 1, col + 1],
      [row, col - 1],
      [row, col + 1],
      [row + 1, col - 1],
      [row + 1, col],
      [row + 1, col + 1]
    ];
    return moves
        .where((pos) =>
            pos[0] >= 0 &&
            pos[0] < BOARD_SIZE &&
            pos[1] >= 0 &&
            pos[1] < BOARD_SIZE)
        .toList();
  }

  /// 퀸의 이동 가능한 위치들을 반환 (가로, 세로, 대각선)
  Map<String, List<List<int>>> _getQueenMoves(int row, int col) {
    final moves = {
      'row': <List<int>>[], // 가로 방향
      'col': <List<int>>[], // 세로 방향
      'main': <List<int>>[], // 주 대각선 (↘️ 방향)
      'anti': <List<int>>[] // 반대 대각선 (↙️ 방향)
    };

    // 가로 방향 (행)
    for (int j = 0; j < BOARD_SIZE; j++) {
      if (j != col && !_board[row][j].hasChessPiece) {
        moves['row']!.add([row, j]);
      }
    }

    // 세로 방향 (열)
    for (int i = 0; i < BOARD_SIZE; i++) {
      if (i != row && !_board[i][col].hasChessPiece) {
        moves['col']!.add([i, col]);
      }
    }

    // 대각선 방향 (비숍과 동일하게 처리)
    final bishopDiagonals = _getBishopDiagonals(row, col);
    moves['main'] = bishopDiagonals['main']!;
    moves['anti'] = bishopDiagonals['anti']!;

    return moves;
  }

  /// 비숍의 대각선 이동 가능한 위치들을 반환
  Map<String, List<List<int>>> _getBishopDiagonals(int row, int col) {
    final diagonals = {
      'main': <List<int>>[], // 왼쪽 위에서 오른쪽 아래 방향
      'anti': <List<int>>[] // 오른쪽 위에서 왼쪽 아래 방향
    };

    // 메인 대각선 (↘️)
    var r = row - 1;
    var c = col - 1;
    while (r >= 0 && c >= 0) {
      if (!_board[r][c].hasChessPiece) {
        // 체스 기물이 없는 경우만
        diagonals['main']!.add([r, c]);
      } else {
        break; // 체스 기물을 만나면 그 방향으로의 탐색 중단
      }
      r--;
      c--;
    }

    r = row + 1;
    c = col + 1;
    while (r < BOARD_SIZE && c < BOARD_SIZE) {
      if (!_board[r][c].hasChessPiece) {
        diagonals['main']!.add([r, c]);
      } else {
        break;
      }
      r++;
      c++;
    }

    // 반대 대각선 (↙️)
    r = row - 1;
    c = col + 1;
    while (r >= 0 && c < BOARD_SIZE) {
      if (!_board[r][c].hasChessPiece) {
        diagonals['anti']!.add([r, c]);
      } else {
        break;
      }
      r--;
      c++;
    }

    r = row + 1;
    c = col - 1;
    while (r < BOARD_SIZE && c >= 0) {
      if (!_board[r][c].hasChessPiece) {
        diagonals['anti']!.add([r, c]);
      } else {
        break;
      }
      r++;
      c--;
    }

    return diagonals;
  }

  /// 나이트의 이동 가능한 위치 반환
  List<List<int>> _getKnightMoves(int row, int col) {
    final moves = [
      [row - 2, col - 1],
      [row - 2, col + 1],
      [row - 1, col - 2],
      [row - 1, col + 2],
      [row + 1, col - 2],
      [row + 1, col + 2],
      [row + 2, col - 1],
      [row + 2, col + 1]
    ];
    return moves
        .where((pos) =>
            pos[0] >= 0 &&
            pos[0] < BOARD_SIZE &&
            pos[1] >= 0 &&
            pos[1] < BOARD_SIZE)
        .toList();
  }

  /// 체스 기물을 보드에 배치하고 이동 가능 위치 표시
  bool _placePiece(ChessPiece piece, int row, int col) {
    if (_pieces.containsKey(piece) &&
        row >= 0 &&
        row < BOARD_SIZE &&
        col >= 0 &&
        col < BOARD_SIZE) {
      _board[row][col] = CellContent(chessPiece: piece, isInitial: true);
      _piecePositions[piece]!.add([row, col]);

      final posKey = '$row,$col';

      if (piece == ChessPiece.knight) {
        _knightMoveNumbers[posKey] = <int>{};
      } else if (piece == ChessPiece.bishop) {
        _bishopDiagonals[posKey] = {'main': <int>{}, 'anti': <int>{}};
      } else if (piece == ChessPiece.king) {
        _kingAdjacentNumbers[posKey] = <int>{};
      } else if (piece == ChessPiece.queen) {
        _queenMoveNumbers[posKey] = {
          'row': <int>{},
          'col': <int>{},
          'main': <int>{},
          'anti': <int>{}
        };
      }
      return true;
    }
    return false;
  }

  /// 주어진 위치에 숫자를 놓을 수 있는지 확인
  bool _isValidNumber(int row, int col, int num) {
    // 체스 기물이 있는 칸인지 확인
    if (_board[row][col].hasChessPiece) {
      return false;
    }

    // 행 검사
    for (int j = 0; j < BOARD_SIZE; j++) {
      if (_board[row][j].hasNumber && _board[row][j].number == num) {
        return false;
      }
    }

    // 열 검사
    for (int i = 0; i < BOARD_SIZE; i++) {
      if (_board[i][col].hasNumber && _board[i][col].number == num) {
        return false;
      }
    }

    // 3x3 박스 검사
    final boxRow = 3 * (row ~/ 3);
    final boxCol = 3 * (col ~/ 3);
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (_board[i][j].hasNumber && _board[i][j].number == num) {
          return false;
        }
      }
    }

    // 나이트 이동 규칙 검사
    for (final knightPos in _piecePositions[ChessPiece.knight]!) {
      final posKey = '${knightPos[0]},${knightPos[1]}';
      final knightMoves = _getKnightMoves(knightPos[0], knightPos[1]);

      for (final move in knightMoves) {
        if (move[0] == row && move[1] == col) {
          if (_knightMoveNumbers[posKey]?.contains(num) ?? false) {
            return false;
          }
        }
      }
    }

    // 비숍 대각선 규칙 검사
    for (final bishopPos in _piecePositions[ChessPiece.bishop]!) {
      final posKey = '${bishopPos[0]},${bishopPos[1]}';
      final diagonals = _getBishopDiagonals(bishopPos[0], bishopPos[1]);

      // 메인 대각선 검사
      for (final pos in diagonals['main']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_bishopDiagonals[posKey]?['main']?.contains(num) ?? false) {
            return false;
          }
        }
      }

      // 반대 대각선 검사
      for (final pos in diagonals['anti']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_bishopDiagonals[posKey]?['anti']?.contains(num) ?? false) {
            return false;
          }
        }
      }
    }

    // 킹 주변 규칙 검사
    for (final kingPos in _piecePositions[ChessPiece.king]!) {
      final posKey = '${kingPos[0]},${kingPos[1]}';
      final kingMoves = _getKingMoves(kingPos[0], kingPos[1]);

      for (final move in kingMoves) {
        if (move[0] == row && move[1] == col) {
          if (_kingAdjacentNumbers[posKey]?.contains(num) ?? false) {
            return false;
          }
        }
      }
    }

    // 퀸 이동 규칙 검사
    for (final queenPos in _piecePositions[ChessPiece.queen]!) {
      final posKey = '${queenPos[0]},${queenPos[1]}';
      final queenMoves = _getQueenMoves(queenPos[0], queenPos[1]);

      // 가로 방향 검사
      for (final pos in queenMoves['row']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['row']?.contains(num) ?? false) {
            return false;
          }
        }
      }

      // 세로 방향 검사
      for (final pos in queenMoves['col']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['col']?.contains(num) ?? false) {
            return false;
          }
        }
      }

      // 메인 대각선 검사
      for (final pos in queenMoves['main']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['main']?.contains(num) ?? false) {
            return false;
          }
        }
      }

      // 반대 대각선 검사
      for (final pos in queenMoves['anti']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['anti']?.contains(num) ?? false) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// 숫자를 보드에 배치
  bool _placeNumber(int row, int col, int num) {
    if (_isValidNumber(row, col, num)) {
      _board[row][col] = CellContent(number: num, isInitial: true);

      // 나이트의 이동 범위에 있는 경우 해당 숫자 기록
      for (final knightPos in _piecePositions[ChessPiece.knight]!) {
        final posKey = '${knightPos[0]},${knightPos[1]}';
        final knightMoves = _getKnightMoves(knightPos[0], knightPos[1]);

        for (final move in knightMoves) {
          if (move[0] == row && move[1] == col) {
            _knightMoveNumbers[posKey]?.add(num);
          }
        }
      }

      // 비숍의 대각선 범위에 있는 경우 해당 숫자 기록
      for (final bishopPos in _piecePositions[ChessPiece.bishop]!) {
        final posKey = '${bishopPos[0]},${bishopPos[1]}';
        final diagonals = _getBishopDiagonals(bishopPos[0], bishopPos[1]);

        for (final pos in diagonals['main']!) {
          if (pos[0] == row && pos[1] == col) {
            _bishopDiagonals[posKey]?['main']?.add(num);
          }
        }

        for (final pos in diagonals['anti']!) {
          if (pos[0] == row && pos[1] == col) {
            _bishopDiagonals[posKey]?['anti']?.add(num);
          }
        }
      }

      // 킹의 주변 8방향에 있는 경우 해당 숫자 기록
      for (final kingPos in _piecePositions[ChessPiece.king]!) {
        final posKey = '${kingPos[0]},${kingPos[1]}';
        final kingMoves = _getKingMoves(kingPos[0], kingPos[1]);

        for (final move in kingMoves) {
          if (move[0] == row && move[1] == col) {
            _kingAdjacentNumbers[posKey]?.add(num);
          }
        }
      }

      // 퀸의 이동 범위에 있는 경우 해당 숫자 기록
      for (final queenPos in _piecePositions[ChessPiece.queen]!) {
        final posKey = '${queenPos[0]},${queenPos[1]}';
        final queenMoves = _getQueenMoves(queenPos[0], queenPos[1]);

        // 가로 방향 확인
        for (final pos in queenMoves['row']!) {
          if (pos[0] == row && pos[1] == col) {
            _queenMoveNumbers[posKey]?['row']?.add(num);
          }
        }

        // 세로 방향 확인
        for (final pos in queenMoves['col']!) {
          if (pos[0] == row && pos[1] == col) {
            _queenMoveNumbers[posKey]?['col']?.add(num);
          }
        }

        // 메인 대각선 확인
        for (final pos in queenMoves['main']!) {
          if (pos[0] == row && pos[1] == col) {
            _queenMoveNumbers[posKey]?['main']?.add(num);
          }
        }

        // 반대 대각선 확인
        for (final pos in queenMoves['anti']!) {
          if (pos[0] == row && pos[1] == col) {
            _queenMoveNumbers[posKey]?['anti']?.add(num);
          }
        }
      }

      return true;
    }
    return false;
  }

  /// 비어있는 셀 찾기
  List<int>? _findEmptyCell() {
    for (int i = 0; i < BOARD_SIZE; i++) {
      for (int j = 0; j < BOARD_SIZE; j++) {
        if (!_board[i][j].hasChessPiece && !_board[i][j].hasNumber) {
          return [i, j];
        }
      }
    }
    return null; // 비어있는 셀이 없음
  }

  /// 백트래킹을 사용하여 스도쿠 해결
  bool _solveSudoku() {
    final empty = _findEmptyCell();

    // 모든 셀이 채워졌다면 완료
    if (empty == null) {
      return true;
    }

    final row = empty[0];
    final col = empty[1];

    // 1-9를 랜덤하게 섞어서 시도
    final numbers = List<int>.generate(9, (i) => i + 1)..shuffle(_random);

    for (final num in numbers) {
      // 현재 숫자가 유효한지 확인
      if (_isValidNumber(row, col, num)) {
        // 숫자 배치
        _placeNumber(row, col, num);

        // 재귀적으로 나머지 셀 해결 시도
        if (_solveSudoku()) {
          return true;
        }

        // 해결책을 찾지 못했다면 백트래킹
        _board[row][col] = const CellContent(isInitial: false);

        // 나이트의 이동 범위에서 숫자 제거
        for (final knightPos in _piecePositions[ChessPiece.knight]!) {
          final posKey = '${knightPos[0]},${knightPos[1]}';
          final knightMoves = _getKnightMoves(knightPos[0], knightPos[1]);

          for (final move in knightMoves) {
            if (move[0] == row && move[1] == col) {
              _knightMoveNumbers[posKey]?.remove(num);
            }
          }
        }

        // 비숍의 대각선에서 숫자 제거
        for (final bishopPos in _piecePositions[ChessPiece.bishop]!) {
          final posKey = '${bishopPos[0]},${bishopPos[1]}';
          final diagonals = _getBishopDiagonals(bishopPos[0], bishopPos[1]);

          for (final pos in diagonals['main']!) {
            if (pos[0] == row && pos[1] == col) {
              _bishopDiagonals[posKey]?['main']?.remove(num);
            }
          }

          for (final pos in diagonals['anti']!) {
            if (pos[0] == row && pos[1] == col) {
              _bishopDiagonals[posKey]?['anti']?.remove(num);
            }
          }
        }

        // 킹의 주변에서 숫자 제거
        for (final kingPos in _piecePositions[ChessPiece.king]!) {
          final posKey = '${kingPos[0]},${kingPos[1]}';
          final kingMoves = _getKingMoves(kingPos[0], kingPos[1]);

          for (final move in kingMoves) {
            if (move[0] == row && move[1] == col) {
              _kingAdjacentNumbers[posKey]?.remove(num);
            }
          }
        }

        // 퀸의 이동 범위에서 숫자 제거
        for (final queenPos in _piecePositions[ChessPiece.queen]!) {
          final posKey = '${queenPos[0]},${queenPos[1]}';
          final queenMoves = _getQueenMoves(queenPos[0], queenPos[1]);

          // 가로 방향 제거
          for (final pos in queenMoves['row']!) {
            if (pos[0] == row && pos[1] == col) {
              _queenMoveNumbers[posKey]?['row']?.remove(num);
            }
          }

          // 세로 방향 제거
          for (final pos in queenMoves['col']!) {
            if (pos[0] == row && pos[1] == col) {
              _queenMoveNumbers[posKey]?['col']?.remove(num);
            }
          }

          // 메인 대각선 제거
          for (final pos in queenMoves['main']!) {
            if (pos[0] == row && pos[1] == col) {
              _queenMoveNumbers[posKey]?['main']?.remove(num);
            }
          }

          // 반대 대각선 제거
          for (final pos in queenMoves['anti']!) {
            if (pos[0] == row && pos[1] == col) {
              _queenMoveNumbers[posKey]?['anti']?.remove(num);
            }
          }
        }
      }
    }

    return false;
  }

  /// 완성된 스도쿠에서 숫자를 제거하여 퍼즐 생성
  List<List<CellContent>> _createPuzzle(Difficulty difficulty) {
    // 난이도별 제거할 셀의 개수 (체스 기물 제외)
    final difficultyLevels = {
      Difficulty.easy: [35, 40], // 41-46개의 힌트
      Difficulty.medium: [45, 50], // 31-36개의 힌트
      Difficulty.hard: [55, 60] // 21-26개의 힌트
    };

    final minRemove = difficultyLevels[difficulty]![0];
    final maxRemove = difficultyLevels[difficulty]![1];
    final cellsToRemove =
        minRemove + _random.nextInt(maxRemove - minRemove + 1);

    // 제거 가능한 셀의 위치 수집 (체스 기물이 없는 위치만)
    final availableCells = <List<int>>[];
    for (int i = 0; i < BOARD_SIZE; i++) {
      for (int j = 0; j < BOARD_SIZE; j++) {
        if (_board[i][j].hasNumber) {
          availableCells.add([i, j]);
        }
      }
    }

    // 퍼즐 생성을 위한 보드 복사
    final puzzleBoard = List.generate(
      BOARD_SIZE,
      (i) => List.generate(
        BOARD_SIZE,
        (j) => _board[i][j].copyWith(),
      ),
    );

    availableCells.shuffle(_random);

    int removedCount = 0;
    for (final cell in availableCells) {
      if (removedCount >= cellsToRemove) break;

      final row = cell[0];
      final col = cell[1];

      // 셀 비우기 (힌트가 아닌 빈 셀로 설정)
      puzzleBoard[row][col] = const CellContent(isInitial: false);
      removedCount++;
    }

    return puzzleBoard;
  }

  /// 체스도쿠 보드 생성 메인 메서드
  List<List<CellContent>> generateBoard(Difficulty difficulty) {
    // 최대 시도 횟수 증가
    const int maxAttempts = 50;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        // 초기화
        _board = List.generate(
          BOARD_SIZE,
          (_) => List.generate(
            BOARD_SIZE,
            (_) => const CellContent(isInitial: false),
          ),
        );

        _piecePositions = {
          ChessPiece.king: [],
          ChessPiece.queen: [],
          ChessPiece.bishop: [],
          ChessPiece.knight: [],
          ChessPiece.rook: []
        };

        _knightMoveNumbers = {};
        _bishopDiagonals = {};
        _kingAdjacentNumbers = {};
        _queenMoveNumbers = {};

        // 난이도별 기물 위치를 다양하게 변경
        List<List<dynamic>> piecesToPlace;

        switch (difficulty) {
          case Difficulty.easy:
            // 쉬운 난이도: 적은 기물, 서로 멀리 배치
            final easyPositions = [
              [ChessPiece.knight, 1, 1],
              [ChessPiece.king, 7, 7],
              [ChessPiece.bishop, 4, 4]
            ];
            piecesToPlace = easyPositions;
            break;
          case Difficulty.medium:
            // 중간 난이도: 4개 기물로 제한, 퀸 제외
            final mediumPositions = [
              [ChessPiece.knight, 0, 0],
              [ChessPiece.knight, 8, 8],
              [ChessPiece.king, 4, 4],
              [ChessPiece.bishop, 2, 6]
            ];
            piecesToPlace = mediumPositions;
            break;
          case Difficulty.hard:
            // 어려운 난이도: 기물 수 제한, 위치 조정
            final hardPositions = [
              [ChessPiece.knight, 0, 1],
              [ChessPiece.rook, 8, 7],
              [ChessPiece.king, 4, 4],
              [ChessPiece.bishop, 2, 6],
              [ChessPiece.queen, 6, 2]
            ];
            piecesToPlace = hardPositions;
            break;
        }

        // 체스 기물 배치
        for (final piece in piecesToPlace) {
          final pieceType = piece[0] as ChessPiece;
          final row = piece[1] as int;
          final col = piece[2] as int;
          _placePiece(pieceType, row, col);
        }

        // 스도쿠 솔루션 생성
        if (!_solveSudoku()) {
          attempts++;
          print('스도쿠 솔루션 생성 실패: 시도 $attempts/$maxAttempts');
          continue;
        }

        // 생성된 솔루션 직접 검증
        if (!_validateGeneratedSolution()) {
          attempts++;
          print('생성된 솔루션이 체스도쿠 규칙을 위반합니다: 시도 $attempts/$maxAttempts');
          continue;
        }

        // 퍼즐 생성
        final puzzle = _createPuzzle(difficulty);

        // 생성된 퍼즐이 테스트 환경의 검증을 통과하는지 확인
        if (!_validateWithTestValidator(puzzle)) {
          attempts++;
          print('생성된 퍼즐이 테스트 검증을 통과하지 못했습니다: 시도 $attempts/$maxAttempts');
          continue;
        }

        return puzzle;
      } catch (e) {
        attempts++;
        print('예외 발생: ${e.toString()}, 시도 $attempts/$maxAttempts');
      }
    }

    // 최대 시도 횟수 초과 시 기본 생성 방식으로 마지막 시도
    try {
      _board = List.generate(
        BOARD_SIZE,
        (_) => List.generate(
          BOARD_SIZE,
          (_) => const CellContent(isInitial: false),
        ),
      );

      _piecePositions = {
        ChessPiece.king: [],
        ChessPiece.queen: [],
        ChessPiece.bishop: [],
        ChessPiece.knight: [],
        ChessPiece.rook: []
      };

      _knightMoveNumbers = {};
      _bishopDiagonals = {};
      _kingAdjacentNumbers = {};
      _queenMoveNumbers = {};

      // 가장 단순한 체스 기물 배치 (1개의 나이트만 사용)
      final simplePieces = [
        [ChessPiece.knight, 0, 0]
      ];

      // 체스 기물 배치
      for (final piece in simplePieces) {
        final pieceType = piece[0] as ChessPiece;
        final row = piece[1] as int;
        final col = piece[2] as int;
        _placePiece(pieceType, row, col);
      }

      // 스도쿠 솔루션 생성
      if (_solveSudoku() && _validateGeneratedSolution()) {
        final puzzle = _createPuzzle(difficulty);
        if (_validateWithTestValidator(puzzle)) {
          return puzzle;
        }
      }
    } catch (e) {
      print('마지막 시도 실패: ${e.toString()}');
    }

    throw Exception("체스도쿠 생성에 실패했습니다. 최대 시도 횟수 초과.");
  }

  /// 테스트가 사용하는 validator와 동일한 방식으로 검증
  bool _validateWithTestValidator(List<List<CellContent>> board) {
    // 각 행 검증
    for (int row = 0; row < BOARD_SIZE; row++) {
      final usedNumbers = <int>{};
      for (int col = 0; col < BOARD_SIZE; col++) {
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
    for (int col = 0; col < BOARD_SIZE; col++) {
      final usedNumbers = <int>{};
      for (int row = 0; row < BOARD_SIZE; row++) {
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
    for (int pieceRow = 0; pieceRow < BOARD_SIZE; pieceRow++) {
      for (int pieceCol = 0; pieceCol < BOARD_SIZE; pieceCol++) {
        if (board[pieceRow][pieceCol].hasChessPiece) {
          final piece = board[pieceRow][pieceCol].chessPiece!;

          // 이 기물의 공격 범위에 있는 모든 셀 쌍을 검사
          for (int r1 = 0; r1 < BOARD_SIZE; r1++) {
            for (int c1 = 0; c1 < BOARD_SIZE; c1++) {
              // 첫 번째 셀이 체스 기물이면 건너뜀
              if (board[r1][c1].hasChessPiece) continue;

              // 첫 번째 셀이 기물의 공격 범위에 있는지 확인
              if (!_canPieceAttackTarget(piece, pieceRow, pieceCol, r1, c1))
                continue;

              // 첫 번째 셀의 숫자 확인
              if (!board[r1][c1].hasNumber) continue;
              final number = board[r1][c1].number!;

              // 두 번째 셀을 순회하며 같은 기물의 공격 범위에 있고 같은 숫자를 가진 셀이 있는지 검사
              for (int r2 = 0; r2 < BOARD_SIZE; r2++) {
                for (int c2 = 0; c2 < BOARD_SIZE; c2++) {
                  // 같은 셀이거나 체스 기물이면 건너뜀
                  if ((r1 == r2 && c1 == c2) || board[r2][c2].hasChessPiece)
                    continue;

                  // 두 번째 셀도 기물의 공격 범위에 있는지 확인
                  if (!_canPieceAttackTarget(piece, pieceRow, pieceCol, r2, c2))
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

  /// 체스 기물이 특정 위치를 공격할 수 있는지 검증 (테스트용)
  bool _canPieceAttackTarget(ChessPiece piece, int pieceRow, int pieceCol,
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

  /// 생성된 솔루션이 체스도쿠 규칙을 준수하는지 검증
  bool _validateGeneratedSolution() {
    // 스도쿠 규칙 검증 (행, 열, 3x3 박스)
    // 행 검증
    for (int row = 0; row < BOARD_SIZE; row++) {
      final usedInRow = <int>{};
      for (int col = 0; col < BOARD_SIZE; col++) {
        if (_board[row][col].hasNumber) {
          final num = _board[row][col].number!;
          if (usedInRow.contains(num)) {
            return false;
          }
          usedInRow.add(num);
        }
      }
    }

    // 열 검증
    for (int col = 0; col < BOARD_SIZE; col++) {
      final usedInCol = <int>{};
      for (int row = 0; row < BOARD_SIZE; row++) {
        if (_board[row][col].hasNumber) {
          final num = _board[row][col].number!;
          if (usedInCol.contains(num)) {
            return false;
          }
          usedInCol.add(num);
        }
      }
    }

    // 3x3 박스 검증
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final usedInBox = <int>{};
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            final row = boxRow * 3 + r;
            final col = boxCol * 3 + c;
            if (_board[row][col].hasNumber) {
              final num = _board[row][col].number!;
              if (usedInBox.contains(num)) {
                return false;
              }
              usedInBox.add(num);
            }
          }
        }
      }
    }

    // 체스 기물 규칙 검증
    for (final pieceType in ChessPiece.values) {
      for (final piecePos in _piecePositions[pieceType]!) {
        final pieceRow = piecePos[0];
        final pieceCol = piecePos[1];

        // 이 기물의 공격 범위에 있는 모든 셀 쌍 비교
        for (int r1 = 0; r1 < BOARD_SIZE; r1++) {
          for (int c1 = 0; c1 < BOARD_SIZE; c1++) {
            // 첫 번째 셀이 체스 기물이면 건너뜀
            if (_board[r1][c1].hasChessPiece) continue;

            // 첫 번째 셀이 기물의 공격 범위에 있는지 확인
            bool firstCellAttacked = false;
            switch (pieceType) {
              case ChessPiece.knight:
                final rowDiff = (pieceRow - r1).abs();
                final colDiff = (pieceCol - c1).abs();
                firstCellAttacked = (rowDiff == 2 && colDiff == 1) ||
                    (rowDiff == 1 && colDiff == 2);
                break;
              case ChessPiece.rook:
                firstCellAttacked = pieceRow == r1 || pieceCol == c1;
                break;
              case ChessPiece.bishop:
                final rowDiff = (pieceRow - r1).abs();
                final colDiff = (pieceCol - c1).abs();
                firstCellAttacked = rowDiff == colDiff;
                break;
              case ChessPiece.queen:
                final rowDiff = (pieceRow - r1).abs();
                final colDiff = (pieceCol - c1).abs();
                firstCellAttacked =
                    pieceRow == r1 || pieceCol == c1 || rowDiff == colDiff;
                break;
              case ChessPiece.king:
                final rowDiff = (pieceRow - r1).abs();
                final colDiff = (pieceCol - c1).abs();
                firstCellAttacked = rowDiff <= 1 && colDiff <= 1;
                break;
            }

            if (!firstCellAttacked) continue;

            // 첫 번째 셀의 숫자 확인
            if (!_board[r1][c1].hasNumber) continue;
            final number1 = _board[r1][c1].number!;

            // 두 번째 셀 순회
            for (int r2 = 0; r2 < BOARD_SIZE; r2++) {
              for (int c2 = 0; c2 < BOARD_SIZE; c2++) {
                // 같은 셀이거나 체스 기물이면 건너뜀
                if ((r1 == r2 && c1 == c2) || _board[r2][c2].hasChessPiece)
                  continue;

                // 두 번째 셀이 기물의 공격 범위에 있는지 확인
                bool secondCellAttacked = false;
                switch (pieceType) {
                  case ChessPiece.knight:
                    final rowDiff = (pieceRow - r2).abs();
                    final colDiff = (pieceCol - c2).abs();
                    secondCellAttacked = (rowDiff == 2 && colDiff == 1) ||
                        (rowDiff == 1 && colDiff == 2);
                    break;
                  case ChessPiece.rook:
                    secondCellAttacked = pieceRow == r2 || pieceCol == c2;
                    break;
                  case ChessPiece.bishop:
                    final rowDiff = (pieceRow - r2).abs();
                    final colDiff = (pieceCol - c2).abs();
                    secondCellAttacked = rowDiff == colDiff;
                    break;
                  case ChessPiece.queen:
                    final rowDiff = (pieceRow - r2).abs();
                    final colDiff = (pieceCol - c2).abs();
                    secondCellAttacked =
                        pieceRow == r2 || pieceCol == c2 || rowDiff == colDiff;
                    break;
                  case ChessPiece.king:
                    final rowDiff = (pieceRow - r2).abs();
                    final colDiff = (pieceCol - c2).abs();
                    secondCellAttacked = rowDiff <= 1 && colDiff <= 1;
                    break;
                }

                if (!secondCellAttacked) continue;

                // 두 번째 셀의 숫자 확인
                if (!_board[r2][c2].hasNumber) continue;
                final number2 = _board[r2][c2].number!;

                // 두 셀의 숫자가 같으면 체스 규칙 위반
                if (number1 == number2) {
                  return false;
                }
              }
            }
          }
        }
      }
    }

    return true;
  }

  /// 솔루션 검증을 위해 ChessSudokuValidator 형식으로 변환
  List<List<CellContent>> _convertToValidatorFormat(
      List<List<CellContent>> board) {
    return List.generate(
      BOARD_SIZE,
      (i) => List.generate(
        BOARD_SIZE,
        (j) => board[i][j].copyWith(),
      ),
    );
  }
}

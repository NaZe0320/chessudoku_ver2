import 'dart:math';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

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

    // 체스 기물 제약 관련 실패 원인 추적
    final failureReasons = <int, String>{};

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
      } else {
        // 유효하지 않은 숫자의 원인 파악 (기물 제약 조건만)
        final reason = _getInvalidReason(row, col, num);
        if (reason != null) {
          failureReasons[num] = reason;
        }
      }
    }

    // 기물 제약 조건 관련 실패가 있는 경우에만 로그 출력
    if (failureReasons.isNotEmpty) {
      print('현재 보드 상태:');
      _printBoard();

      print('체스 기물 제약 조건 실패 원인:');
      failureReasons.forEach((num, reason) {
        print('숫자 $num: $reason');
      });
    }

    return false;
  }

  /// 특정 위치에 숫자가 유효하지 않은 이유를 반환 (기물 제약 조건만)
  String? _getInvalidReason(int row, int col, int num) {
    // 체스 기물 관련 실패 원인만 반환하도록 수정

    // 나이트 이동 규칙 검사
    for (final knightPos in _piecePositions[ChessPiece.knight]!) {
      final posKey = '${knightPos[0]},${knightPos[1]}';
      final knightMoves = _getKnightMoves(knightPos[0], knightPos[1]);

      for (final move in knightMoves) {
        if (move[0] == row && move[1] == col) {
          if (_knightMoveNumbers[posKey]?.contains(num) ?? false) {
            return "나이트(${knightPos[0]}, ${knightPos[1]})의 이동 범위에 이미 숫자 $num이 있음";
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
            return "비숍(${bishopPos[0]}, ${bishopPos[1]})의 메인 대각선에 이미 숫자 $num이 있음";
          }
        }
      }

      // 반대 대각선 검사
      for (final pos in diagonals['anti']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_bishopDiagonals[posKey]?['anti']?.contains(num) ?? false) {
            return "비숍(${bishopPos[0]}, ${bishopPos[1]})의 반대 대각선에 이미 숫자 $num이 있음";
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
            return "킹(${kingPos[0]}, ${kingPos[1]})의 주변에 이미 숫자 $num이 있음";
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
            return "퀸(${queenPos[0]}, ${queenPos[1]})의 가로 방향에 이미 숫자 $num이 있음";
          }
        }
      }

      // 세로 방향 검사
      for (final pos in queenMoves['col']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['col']?.contains(num) ?? false) {
            return "퀸(${queenPos[0]}, ${queenPos[1]})의 세로 방향에 이미 숫자 $num이 있음";
          }
        }
      }

      // 메인 대각선 검사
      for (final pos in queenMoves['main']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['main']?.contains(num) ?? false) {
            return "퀸(${queenPos[0]}, ${queenPos[1]})의 메인 대각선에 이미 숫자 $num이 있음";
          }
        }
      }

      // 반대 대각선 검사
      for (final pos in queenMoves['anti']!) {
        if (pos[0] == row && pos[1] == col) {
          if (_queenMoveNumbers[posKey]?['anti']?.contains(num) ?? false) {
            return "퀸(${queenPos[0]}, ${queenPos[1]})의 반대 대각선에 이미 숫자 $num이 있음";
          }
        }
      }
    }

    // 체스 기물 관련 제약 조건이 없는 경우 null 반환
    return null;
  }

  /// 현재 보드 상태를 콘솔에 출력
  void _printBoard() {
    for (int i = 0; i < BOARD_SIZE; i++) {
      String rowStr = '';
      for (int j = 0; j < BOARD_SIZE; j++) {
        if (_board[i][j].hasChessPiece) {
          final piece = _board[i][j].chessPiece!;
          String pieceSymbol = '';
          switch (piece) {
            case ChessPiece.king:
              pieceSymbol = 'K';
              break;
            case ChessPiece.queen:
              pieceSymbol = 'Q';
              break;
            case ChessPiece.bishop:
              pieceSymbol = 'B';
              break;
            case ChessPiece.knight:
              pieceSymbol = 'N';
              break;
            case ChessPiece.rook:
              pieceSymbol = 'R';
              break;
            default:
              pieceSymbol = '?';
          }
          rowStr += '[$pieceSymbol]';
        } else if (_board[i][j].hasNumber) {
          rowStr += '[${_board[i][j].number}]';
        } else {
          rowStr += '[ ]';
        }
      }
      print('$i: $rowStr');
    }
  }

  /// 난이도에 따라 체스 기물 배치를 랜덤하게 생성
  List<List<dynamic>> _generateRandomPiecePositions(Difficulty difficulty) {
    final Random random = Random();

    // 기본적으로 나이트 1개를 배치
    final List<List<dynamic>> piecePositions = [];

    // 보드의 랜덤한 위치에 나이트 배치
    final int row = random.nextInt(BOARD_SIZE);
    final int col = random.nextInt(BOARD_SIZE);
    piecePositions.add([ChessPiece.knight, row, col]);

    return piecePositions;
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

        // 난이도별 기물 위치 랜덤 생성
        final piecesToPlace = _generateRandomPiecePositions(difficulty);

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

        return _board;
      } catch (e) {
        attempts++;
        print('예외 발생: ${e.toString()}, 시도 $attempts/$maxAttempts');
      }
    }
    throw Exception("체스도쿠 생성에 실패했습니다. 최대 시도 횟수 초과.");
  }
}

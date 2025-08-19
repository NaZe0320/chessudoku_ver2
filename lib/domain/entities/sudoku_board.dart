import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/entities/position.dart';
import 'package:chessudoku/domain/entities/cell_content.dart';
import 'package:chessudoku/core/enums/chess_piece.dart';
import 'dart:developer' as developer;

part 'sudoku_board.freezed.dart';

/// 9x9 스도쿠 보드를 나타내는 모델
@freezed
class SudokuBoard with _$SudokuBoard {
  const factory SudokuBoard({
    @Default({}) Map<Position, CellContent> cells,
  }) = _SudokuBoard;

  const SudokuBoard._();

  /// 특정 위치의 셀 내용 가져오기
  CellContent? getCellContent(Position position) {
    return cells[position];
  }

  /// 특정 위치의 셀 내용 설정
  SudokuBoard setCellContent(Position position, CellContent content) {
    final newCells = Map<Position, CellContent>.from(cells);
    newCells[position] = content;
    return copyWith(cells: newCells);
  }

  /// 특정 위치의 셀 내용 제거
  SudokuBoard removeCellContent(Position position) {
    final newCells = Map<Position, CellContent>.from(cells);
    newCells.remove(position);
    return copyWith(cells: newCells);
  }

  /// 빈 보드 생성
  factory SudokuBoard.empty() {
    return const SudokuBoard();
  }

  /// 초기 퍼즐로 보드 생성
  factory SudokuBoard.fromPuzzle(List<List<int?>> puzzle) {
    final cells = <Position, CellContent>{};

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final value = puzzle[row][col];
        if (value != null) {
          final position = Position(row: row, col: col);
          cells[position] = CellContent(
            number: value,
            isInitial: true,
          );
        }
      }
    }

    return SudokuBoard(cells: cells);
  }

  /// 체스 기물을 포함한 퍼즐로 보드 생성
  factory SudokuBoard.fromPuzzleWithChess({
    required List<List<int?>> puzzle,
    required Map<Position, ChessPiece> chessPieces,
  }) {
    final cells = <Position, CellContent>{};
    int cellCount = 0;

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final value = puzzle[row][col];
        final position = Position(row: row, col: col);
        final chessPiece = chessPieces[position];

        if (value != null || chessPiece != null) {
          final finalValue = chessPiece != null ? null : value;

          cells[position] = CellContent(
            number: finalValue,
            chessPiece: chessPiece,
            isInitial: finalValue != null,
          );
          cellCount++;

          if (chessPiece != null) {
            developer.log('체스 기물 셀 생성: ($row, $col) -> $chessPiece',
                name: 'SudokuBoard');
          }
        }
      }
    }

    developer.log('SudokuBoard.fromPuzzleWithChess 완료 - 총 셀 수: $cellCount',
        name: 'SudokuBoard');
    return SudokuBoard(cells: cells);
  }

  /// 특정 행의 모든 숫자 가져오기
  Set<int> getRowNumbers(int row) {
    final numbers = <int>{};
    for (int col = 0; col < 9; col++) {
      final content = getCellContent(Position(row: row, col: col));
      if (content?.number != null) {
        numbers.add(content!.number!);
      }
    }
    return numbers;
  }

  /// 특정 열의 모든 숫자 가져오기
  Set<int> getColNumbers(int col) {
    final numbers = <int>{};
    for (int row = 0; row < 9; row++) {
      final content = getCellContent(Position(row: row, col: col));
      if (content?.number != null) {
        numbers.add(content!.number!);
      }
    }
    return numbers;
  }

  /// 특정 3x3 블록의 모든 숫자 가져오기
  Set<int> getBlockNumbers(int blockRow, int blockCol) {
    final numbers = <int>{};
    final startRow = blockRow * 3;
    final startCol = blockCol * 3;

    for (int row = startRow; row < startRow + 3; row++) {
      for (int col = startCol; col < startCol + 3; col++) {
        final content = getCellContent(Position(row: row, col: col));
        if (content?.number != null) {
          numbers.add(content!.number!);
        }
      }
    }
    return numbers;
  }

  /// 특정 위치에 숫자가 유효한지 확인
  bool isValidMove(Position position, int number) {
    if (getRowNumbers(position.row).contains(number)) {
      return false;
    }

    if (getColNumbers(position.col).contains(number)) {
      return false;
    }

    final blockRow = position.row ~/ 3;
    final blockCol = position.col ~/ 3;
    if (getBlockNumbers(blockRow, blockCol).contains(number)) {
      return false;
    }

    return true;
  }

  /// 체스 기물 제약을 고려한 유효성 검사
  bool isValidWithChessConstraints({
    required Position position,
    required int number,
  }) {
    if (!isValidMove(position, number)) {
      return false;
    }

    bool inBounds(int r, int c) => r >= 0 && r < 9 && c >= 0 && c < 9;

    bool hasSameNumberAt(Position p) {
      final content = getCellContent(p);
      return content?.number == number;
    }

    for (int or = 0; or < 9; or++) {
      for (int oc = 0; oc < 9; oc++) {
        final origin = Position(row: or, col: oc);
        final piece = getCellContent(origin)?.chessPiece;
        if (piece == null) continue;

        switch (piece) {
          case ChessPiece.king:
            bool isInCoverage = false;
            for (int dr = -1; dr <= 1; dr++) {
              for (int dc = -1; dc <= 1; dc++) {
                if (dr == 0 && dc == 0) continue;
                final r = or + dr;
                final c = oc + dc;
                if (!inBounds(r, c)) continue;
                if (position.row == r && position.col == c) {
                  isInCoverage = true;
                }
              }
            }
            if (isInCoverage) {
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final r = or + dr;
                  final c = oc + dc;
                  if (!inBounds(r, c)) continue;
                  if (r == position.row && c == position.col) continue;
                  if (hasSameNumberAt(Position(row: r, col: c))) {
                    return false;
                  }
                }
              }
            }
            break;

          case ChessPiece.knight:
            const deltas = [
              [2, 1],
              [2, -1],
              [-2, 1],
              [-2, -1],
              [1, 2],
              [1, -2],
              [-1, 2],
              [-1, -2],
            ];
            bool isInCoverage = false;
            for (final d in deltas) {
              final r = or + d[0];
              final c = oc + d[1];
              if (!inBounds(r, c)) continue;
              if (position.row == r && position.col == c) {
                isInCoverage = true;
                break;
              }
            }
            if (isInCoverage) {
              for (final d in deltas) {
                final r = or + d[0];
                final c = oc + d[1];
                if (!inBounds(r, c)) continue;
                if (r == position.row && c == position.col) continue;
                if (hasSameNumberAt(Position(row: r, col: c))) {
                  return false;
                }
              }
            }
            break;

          case ChessPiece.bishop:
          case ChessPiece.queen:
            final dr = position.row - or;
            final dc = position.col - oc;
            if (dr == 0 && dc == 0) break;
            if (dr.abs() != dc.abs()) break;

            final bool diagSameSign = (dr > 0 && dc > 0) || (dr < 0 && dc < 0);

            List<List<int>> directions;
            if (diagSameSign) {
              directions = const [
                [1, 1],
                [-1, -1]
              ];
            } else {
              directions = const [
                [1, -1],
                [-1, 1]
              ];
            }

            for (final d in directions) {
              var r = or + d[0];
              var c = oc + d[1];
              while (inBounds(r, c)) {
                if (!(r == position.row && c == position.col) &&
                    hasSameNumberAt(Position(row: r, col: c))) {
                  return false;
                }
                r += d[0];
                c += d[1];
              }
            }
            break;

          case ChessPiece.rook:
            break;

          case ChessPiece.pawn:
            break;
        }
      }
    }

    return true;
  }

  /// 보드가 완성되었는지 확인
  bool get isCompleted {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final content = getCellContent(Position(row: row, col: col));
        if (content?.number == null) {
          return false;
        }
      }
    }
    return true;
  }

  /// 완료된 셀 수 가져오기
  int getCompletedCellsCount() {
    int count = 0;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final content = getCellContent(Position(row: row, col: col));
        if (content?.number != null) {
          count++;
        }
      }
    }
    return count;
  }
}

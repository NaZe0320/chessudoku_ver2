import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'dart:developer' as developer;

/// 9x9 스도쿠 보드를 나타내는 모델
class SudokuBoard {
  final Map<Position, CellContent> cells;

  const SudokuBoard({
    this.cells = const {},
  });

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
            isInitial: true, // 퍼즐의 초기값은 수정 불가
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
          // 체스 기물이 있는 위치에서는 숫자를 제거
          final finalValue = chessPiece != null ? null : value;

          cells[position] = CellContent(
            number: finalValue,
            chessPiece: chessPiece,
            isInitial: finalValue != null, // 숫자가 있으면 초기값
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
    // 행 검사
    if (getRowNumbers(position.row).contains(number)) {
      return false;
    }

    // 열 검사
    if (getColNumbers(position.col).contains(number)) {
      return false;
    }

    // 3x3 블록 검사
    final blockRow = position.row ~/ 3;
    final blockCol = position.col ~/ 3;
    if (getBlockNumbers(blockRow, blockCol).contains(number)) {
      return false;
    }

    return true;
  }

  /// 보드가 완성되었는지 확인
  bool get isCompleted {
    // 모든 셀이 채워져 있는지 확인
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

  /// 완료된 셀 수 가져오기 (숫자가 입력된 셀 수)
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

  /// 보드 복사
  SudokuBoard copyWith({
    Map<Position, CellContent>? cells,
  }) {
    return SudokuBoard(
      cells: cells ?? this.cells,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SudokuBoard &&
        cells.length == other.cells.length &&
        cells.entries.every((entry) => other.cells[entry.key] == entry.value);
  }

  @override
  int get hashCode => cells.hashCode;
}

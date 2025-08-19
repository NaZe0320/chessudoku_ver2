import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/entities/position.dart';
import 'package:chessudoku/domain/entities/sudoku_board.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

part 'game_board.freezed.dart';

/// 게임 진행 상황을 포함한 보드 모델
@freezed
class GameBoard with _$GameBoard {
  const factory GameBoard({
    required SudokuBoard board,
    required SudokuBoard solutionBoard,
    Position? selectedCell,
    @Default({}) Set<Position> highlightedCells,
    @Default({}) Set<Position> errorCells,
    required Difficulty difficulty,
    required String puzzleId,
    @Default(false) bool isNoteMode,
  }) = _GameBoard;

  const GameBoard._();

  /// 빈 게임 보드 생성
  factory GameBoard.empty({
    required Difficulty difficulty,
    required String puzzleId,
  }) {
    return GameBoard(
      board: SudokuBoard.empty(),
      solutionBoard: SudokuBoard.empty(),
      difficulty: difficulty,
      puzzleId: puzzleId,
    );
  }

  /// 퍼즐과 답안으로부터 게임 보드 생성
  factory GameBoard.fromPuzzleAndSolution({
    required List<List<int?>> puzzle,
    required List<List<int?>> solution,
    required Difficulty difficulty,
    required String puzzleId,
  }) {
    return GameBoard(
      board: SudokuBoard.fromPuzzle(puzzle),
      solutionBoard: SudokuBoard.fromPuzzle(solution),
      difficulty: difficulty,
      puzzleId: puzzleId,
    );
  }

  /// 퍼즐로부터 게임 보드 생성 (기존 호환성)
  factory GameBoard.fromPuzzle({
    required List<List<int?>> puzzle,
    required Difficulty difficulty,
    required String puzzleId,
  }) {
    return GameBoard(
      board: SudokuBoard.fromPuzzle(puzzle),
      solutionBoard: SudokuBoard.fromPuzzle(puzzle),
      difficulty: difficulty,
      puzzleId: puzzleId,
    );
  }

  /// 셀 선택
  GameBoard selectCell(Position? position) {
    if (position == selectedCell) {
      return copyWith(
        selectedCell: null,
        highlightedCells: {},
      );
    }

    final highlightedCells =
        position != null ? _getRelatedCells(position) : <Position>{};

    return copyWith(
      selectedCell: position,
      highlightedCells: highlightedCells,
    );
  }

  /// 선택된 셀과 관련된 셀들 가져오기 (같은 행, 열, 블록)
  Set<Position> _getRelatedCells(Position position) {
    final related = <Position>{};

    // 같은 행
    for (int col = 0; col < 9; col++) {
      related.add(Position(row: position.row, col: col));
    }

    // 같은 열
    for (int row = 0; row < 9; row++) {
      related.add(Position(row: row, col: position.col));
    }

    // 같은 3x3 블록
    final blockRow = position.row ~/ 3;
    final blockCol = position.col ~/ 3;
    for (int row = blockRow * 3; row < blockRow * 3 + 3; row++) {
      for (int col = blockCol * 3; col < blockCol * 3 + 3; col++) {
        related.add(Position(row: row, col: col));
      }
    }

    return related;
  }

  /// 특정 위치의 정답 확인
  bool isCorrectAnswer(Position position, int number) {
    final solutionContent = solutionBoard.getCellContent(position);
    return solutionContent?.number == number;
  }

  /// 메모 모드 토글
  GameBoard toggleNoteMode() {
    return copyWith(isNoteMode: !isNoteMode);
  }

  /// 오류 셀 추가
  GameBoard addErrorCell(Position position) {
    final newErrorCells = Set<Position>.from(errorCells);
    newErrorCells.add(position);
    return copyWith(errorCells: newErrorCells);
  }

  /// 오류 셀 제거
  GameBoard removeErrorCell(Position position) {
    final newErrorCells = Set<Position>.from(errorCells);
    newErrorCells.remove(position);
    return copyWith(errorCells: newErrorCells);
  }

  /// 모든 오류 셀 제거
  GameBoard clearErrorCells() {
    return copyWith(errorCells: {});
  }

  /// 게임이 완료되었는지 확인 (답안과 비교)
  bool get isCompleted {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final position = Position(row: row, col: col);
        final currentContent = board.getCellContent(position);

        if (currentContent?.chessPiece != null) continue;

        final solutionContent = solutionBoard.getCellContent(position);
        if (currentContent?.number != solutionContent?.number) {
          return false;
        }
      }
    }
    return true;
  }

  /// 남은 빈 셀 수
  int get remainingCells {
    int count = 0;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final content = board.getCellContent(Position(row: row, col: col));
        if (content?.number == null) {
          count++;
        }
      }
    }
    return count;
  }

  /// 진행률 (0.0 - 1.0)
  double get progress {
    const totalCells = 81;
    final filledCells = totalCells - remainingCells;
    return filledCells / totalCells;
  }

  /// 선택된 셀의 메모 숫자들 가져오기
  Set<int> get selectedCellNotes {
    if (selectedCell == null) return {};

    final cellContent = board.getCellContent(selectedCell!);
    return cellContent?.notes ?? {};
  }
}

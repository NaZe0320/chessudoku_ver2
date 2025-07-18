import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 게임 진행 상황을 포함한 보드 모델
class GameBoard {
  final SudokuBoard board;
  final Position? selectedCell; // 현재 선택된 셀
  final Set<Position> highlightedCells; // 하이라이트된 셀들
  final Set<Position> errorCells; // 오류가 있는 셀들
  final Difficulty difficulty;
  final String puzzleId;
  final bool isNoteMode; // 메모 모드 여부

  const GameBoard({
    required this.board,
    this.selectedCell,
    this.highlightedCells = const {},
    this.errorCells = const {},
    required this.difficulty,
    required this.puzzleId,
    this.isNoteMode = false,
  });

  /// 빈 게임 보드 생성
  factory GameBoard.empty({
    required Difficulty difficulty,
    required String puzzleId,
  }) {
    return GameBoard(
      board: SudokuBoard.empty(),
      difficulty: difficulty,
      puzzleId: puzzleId,
    );
  }

  /// 퍼즐로부터 게임 보드 생성
  factory GameBoard.fromPuzzle({
    required List<List<int?>> puzzle,
    required Difficulty difficulty,
    required String puzzleId,
  }) {
    return GameBoard(
      board: SudokuBoard.fromPuzzle(puzzle),
      difficulty: difficulty,
      puzzleId: puzzleId,
    );
  }

  /// 셀 선택
  GameBoard selectCell(Position? position) {
    if (position == selectedCell) {
      // 같은 셀을 다시 클릭하면 선택 해제
      return copyWith(
        selectedCell: null,
        highlightedCells: {},
      );
    }

    // 새로운 셀 선택 시 관련된 셀들 하이라이트
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

  /// 게임이 완료되었는지 확인
  bool get isCompleted => board.isCompleted;

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

  /// 게임 보드 복사
  GameBoard copyWith({
    SudokuBoard? board,
    Position? selectedCell,
    Set<Position>? highlightedCells,
    Set<Position>? errorCells,
    Difficulty? difficulty,
    String? puzzleId,
    bool? isNoteMode,
  }) {
    return GameBoard(
      board: board ?? this.board,
      selectedCell: selectedCell ?? this.selectedCell,
      highlightedCells: highlightedCells ?? this.highlightedCells,
      errorCells: errorCells ?? this.errorCells,
      difficulty: difficulty ?? this.difficulty,
      puzzleId: puzzleId ?? this.puzzleId,
      isNoteMode: isNoteMode ?? this.isNoteMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameBoard &&
        other.board == board &&
        other.selectedCell == selectedCell &&
        other.highlightedCells.length == highlightedCells.length &&
        other.highlightedCells.containsAll(highlightedCells) &&
        other.errorCells.length == errorCells.length &&
        other.errorCells.containsAll(errorCells) &&
        other.difficulty == difficulty &&
        other.puzzleId == puzzleId &&
        other.isNoteMode == isNoteMode;
  }

  @override
  int get hashCode {
    return board.hashCode ^
        selectedCell.hashCode ^
        highlightedCells.hashCode ^
        errorCells.hashCode ^
        difficulty.hashCode ^
        puzzleId.hashCode ^
        isNoteMode.hashCode;
  }
}

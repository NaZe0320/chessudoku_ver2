import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class PuzzleState {
  final Difficulty difficulty;
  final List<List<CellContent>> board;
  final int? selectedRow;
  final int? selectedCol;
  final bool isCompleted;
  final Duration elapsedTime;
  final bool isPaused;

  const PuzzleState({
    this.difficulty = Difficulty.easy,
    required this.board,
    this.selectedRow,
    this.selectedCol,
    this.isCompleted = false,
    this.elapsedTime = Duration.zero,
    this.isPaused = false,
  });
}

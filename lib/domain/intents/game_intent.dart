import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

abstract class GameIntent {}

class SelectCellIntent extends GameIntent {
  final int row, col;

  SelectCellIntent(this.row, this.col);
}

class InputNumberIntent extends GameIntent {
  final int number;

  InputNumberIntent(this.number);
}

class ClearCellIntent extends GameIntent {}

class ToggleNoteIntent extends GameIntent {
  final int number;

  ToggleNoteIntent(this.number);
}

class StartGameIntent extends GameIntent {
  final String gameId;
  final List<List<CellContent>> initialBoard;
  final Difficulty difficulty;

  StartGameIntent({
    required this.gameId,
    required this.initialBoard,
    required this.difficulty,
  });
}

class PauseGameIntent extends GameIntent {}

class ResumeGameIntent extends GameIntent {}

class CheckGameCompletionIntent extends GameIntent {}

import 'package:chessudoku/data/models/cell_content.dart';

abstract class GameIntent {}

class StartGameIntent extends GameIntent {
  final List<List<CellContent>> board;

  StartGameIntent(this.board);
}

class SelectCellIntent extends GameIntent {
  final int row, col;

  SelectCellIntent(this.row, this.col);
}

class InputNumberIntent extends GameIntent {
  final int number;

  InputNumberIntent(this.number);
}

class UseHintIntent extends GameIntent {}
class PauseGameIntent extends GameIntent {}
class ResumeGameIntent extends GameIntent {}
class CompleteGameIntent extends GameIntent {}


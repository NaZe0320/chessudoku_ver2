import 'package:chessudoku/data/models/cell_content.dart';

abstract class PuzzleIntent {}

class StartPuzzleIntent extends PuzzleIntent {
  final List<List<CellContent>> board;

  StartPuzzleIntent(this.board);
}

class SelectCellIntent extends PuzzleIntent {
  final int row, col;

  SelectCellIntent(this.row, this.col);
}

class InputNumberIntent extends PuzzleIntent {
  final int number;

  InputNumberIntent(this.number);
}

class UseHintIntent extends PuzzleIntent {}

class PausePuzzleIntent extends PuzzleIntent {}

class ResumePuzzleIntent extends PuzzleIntent {}

class CompletePuzzleIntent extends PuzzleIntent {}

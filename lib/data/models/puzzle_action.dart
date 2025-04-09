import 'package:chessudoku/data/models/cell_content.dart';

class PuzzleAction {
  final int row;
  final int col;
  final CellContent oldContent;
  final CellContent newContent;

  PuzzleAction({
    required this.row,
    required this.col,
    required this.oldContent,
    required this.newContent,
  });
}

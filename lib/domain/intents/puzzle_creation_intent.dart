import 'package:chessudoku/domain/enums/difficulty.dart';

abstract class PuzzleCreationIntent {}

class CreatePuzzleIntent extends PuzzleCreationIntent {
  final Difficulty difficulty;

  CreatePuzzleIntent(this.difficulty);
}

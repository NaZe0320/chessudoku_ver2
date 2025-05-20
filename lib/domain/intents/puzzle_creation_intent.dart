import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/core/base/base_intent.dart';

abstract class PuzzleCreationIntent extends BaseIntent {}

class CreatePuzzleIntent extends PuzzleCreationIntent {
  final Difficulty difficulty;

  CreatePuzzleIntent(this.difficulty);
}

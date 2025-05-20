import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/core/base/base_intent.dart';

abstract class PuzzleCreationIntent extends BaseIntent {}

//퍼즐 생성
class CreatePuzzleIntent extends PuzzleCreationIntent {
  final Difficulty difficulty;

  CreatePuzzleIntent(this.difficulty);
}

//난이도 선택
class SelectDifficultyIntent extends PuzzleCreationIntent {
  final Difficulty selectedDifficulty;

  SelectDifficultyIntent(this.selectedDifficulty);
}

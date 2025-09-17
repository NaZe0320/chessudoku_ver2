import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

abstract class GamePreparationIntent extends BaseIntent {
  const GamePreparationIntent();
}

class StartGamePreparationIntent extends GamePreparationIntent {
  final Difficulty difficulty;
  final bool isNewGame;

  const StartGamePreparationIntent({
    required this.difficulty,
    required this.isNewGame,
  });
}

class CancelGamePreparationIntent extends GamePreparationIntent {
  const CancelGamePreparationIntent();
}

class RetryGamePreparationIntent extends GamePreparationIntent {
  const RetryGamePreparationIntent();
}

import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

abstract class GamePreparationIntent extends BaseIntent {
  const GamePreparationIntent();
}

/// 게임 준비 시작
class StartGamePreparationIntent extends GamePreparationIntent {
  final Difficulty difficulty;
  final bool isNewGame;

  const StartGamePreparationIntent({
    required this.difficulty,
    this.isNewGame = true,
  });
}

/// 게임 준비 취소
class CancelGamePreparationIntent extends GamePreparationIntent {
  const CancelGamePreparationIntent();
}

/// 게임 준비 재시도
class RetryGamePreparationIntent extends GamePreparationIntent {
  const RetryGamePreparationIntent();
}

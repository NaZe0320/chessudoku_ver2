import 'package:chessudoku/core/base/base_intent.dart';

abstract class GameIntent extends BaseIntent {
  const GameIntent();
}

class SelectNumberIntent extends GameIntent {
  final int number;

  const SelectNumberIntent(this.number);
}

class ClearSelectionIntent extends GameIntent {
  const ClearSelectionIntent();
}

class StartTimerIntent extends GameIntent {
  const StartTimerIntent();
}

class PauseTimerIntent extends GameIntent {
  const PauseTimerIntent();
}

class ResetTimerIntent extends GameIntent {
  const ResetTimerIntent();
}

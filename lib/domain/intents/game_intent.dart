import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/data/models/position.dart';

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

class SelectCellIntent extends GameIntent {
  final Position position;

  const SelectCellIntent(this.position);
}

class InputNumberIntent extends GameIntent {
  final int number;

  const InputNumberIntent(this.number);
}

class ToggleNoteIntent extends GameIntent {
  final int number;

  const ToggleNoteIntent(this.number);
}

class ToggleNoteModeIntent extends GameIntent {
  const ToggleNoteModeIntent();
}

class ClearCellIntent extends GameIntent {
  const ClearCellIntent();
}

class CheckErrorsIntent extends GameIntent {
  const CheckErrorsIntent();
}

class InitializeTestBoardIntent extends GameIntent {
  const InitializeTestBoardIntent();
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

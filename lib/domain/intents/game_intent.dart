import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/game_board.dart';

abstract class GameIntent extends BaseIntent {
  const GameIntent();
}

/// 게임 시작 Intent
class StartGameIntent extends GameIntent {
  final GameBoard preparedBoard;

  const StartGameIntent(this.preparedBoard);
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

class CheckGameCompletionIntent extends GameIntent {
  const CheckGameCompletionIntent();
}

class HideCompletionDialogIntent extends GameIntent {
  const HideCompletionDialogIntent();
}

class CreateCheckpointIntent extends GameIntent {
  final String checkpointId;

  const CreateCheckpointIntent(this.checkpointId);
}

class RestoreCheckpointIntent extends GameIntent {
  final String checkpointId;

  const RestoreCheckpointIntent(this.checkpointId);
}

class DeleteCheckpointIntent extends GameIntent {
  final String checkpointId;

  const DeleteCheckpointIntent(this.checkpointId);
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

class UndoIntent extends GameIntent {
  const UndoIntent();
}

class RedoIntent extends GameIntent {
  const RedoIntent();
}

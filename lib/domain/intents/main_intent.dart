import 'package:chessudoku/core/base/base_intent.dart';

abstract class MainIntent extends BaseIntent {
  const MainIntent();
}

class CheckSavedGameIntent extends MainIntent {
  const CheckSavedGameIntent();
}

class LoadSavedGameIntent extends MainIntent {
  const LoadSavedGameIntent();
}

class ClearSavedGameIntent extends MainIntent {
  const ClearSavedGameIntent();
}

class LoadStatsIntent extends MainIntent {
  const LoadStatsIntent();
}

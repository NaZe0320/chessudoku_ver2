import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

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

// 게임 시작 관련 Intent 추가
class StartNewGameIntent extends MainIntent {
  final Difficulty difficulty;
  const StartNewGameIntent(this.difficulty);
}

class ContinueSavedGameIntent extends MainIntent {
  const ContinueSavedGameIntent();
}

class GetGameStartInfoIntent extends MainIntent {
  const GetGameStartInfoIntent();
}

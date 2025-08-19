import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

abstract class MainIntent extends BaseIntent {
  const MainIntent();
}

class CheckSavedGameIntent extends MainIntent {
  const CheckSavedGameIntent();
}

class ClearSavedGameIntent extends MainIntent {
  const ClearSavedGameIntent();
}

// 게임 시작 관련 Intent 추가
class StartNewGameIntent extends MainIntent {
  final Difficulty difficulty;
  const StartNewGameIntent(this.difficulty);
}

class ContinueSavedGameIntent extends MainIntent {
  final Difficulty? difficulty;
  const ContinueSavedGameIntent([this.difficulty]);
}

class GetGameStartInfoIntent extends MainIntent {
  const GetGameStartInfoIntent();
}

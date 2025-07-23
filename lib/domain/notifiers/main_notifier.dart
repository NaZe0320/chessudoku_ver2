import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/main_intent.dart';
import 'package:chessudoku/domain/states/main_state.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';

class MainNotifier extends BaseNotifier<MainIntent, MainState> {
  final GameSaveRepository _gameSaveRepository;

  MainNotifier(this._gameSaveRepository) : super(const MainState());

  @override
  void onIntent(MainIntent intent) {
    switch (intent) {
      case CheckSavedGameIntent():
        _handleCheckSavedGame();
      case LoadSavedGameIntent():
        _handleLoadSavedGame();
      case ClearSavedGameIntent():
        _handleClearSavedGame();
      case LoadStatsIntent():
        _handleLoadStats();
    }
  }

  Future<void> _handleCheckSavedGame() async {
    state = state.copyWith(isLoading: true);

    try {
      final hasSavedGame = await _gameSaveRepository.hasSavedGame();
      final savedGameInfo =
          hasSavedGame ? await _gameSaveRepository.getSavedGameInfo() : null;

      state = state.copyWith(
        hasSavedGame: hasSavedGame,
        savedGameInfo: savedGameInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasSavedGame: false,
        savedGameInfo: null,
        isLoading: false,
      );
    }
  }

  Future<void> _handleLoadSavedGame() async {
    // TODO: 저장된 게임 로드 구현
  }

  Future<void> _handleClearSavedGame() async {
    try {
      await _gameSaveRepository.clearCurrentGame();
      state = state.copyWith(
        hasSavedGame: false,
        savedGameInfo: null,
      );
    } catch (e) {
      // 에러 처리
    }
  }

  Future<void> _handleLoadStats() async {
    try {
      final completedPuzzles =
          await _gameSaveRepository.getCompletedPuzzlesCount();
      final currentStreak = await _gameSaveRepository.getCurrentStreak();

      state = state.copyWith(
        completedPuzzles: completedPuzzles,
        currentStreak: currentStreak,
      );
    } catch (e) {
      // 에러 처리
    }
  }
}

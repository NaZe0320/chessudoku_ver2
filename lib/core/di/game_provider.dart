import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/notifiers/game_notifier.dart';
import '../../application/states/game_state.dart';
import '../di/providers.dart';

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final gameSaveRepository = ref.watch(gameSaveRepositoryProvider);
  final gameSettings = ref.watch(gameSettingsNotifierProvider.notifier);
  return GameNotifier(
    gameSaveRepository,
    gameSettings,
  );
});

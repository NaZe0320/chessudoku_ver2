import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../application/notifiers/game_notifier.dart';
import '../../application/states/game_state.dart';
import '../di/providers.dart';

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final gameSaveRepository = ref.watch(gameSaveRepositoryProvider);
  final puzzleRecordRepository = ref.watch(puzzleRecordRepositoryProvider);
  final gameSettings = ref.watch(gameSettingsNotifierProvider.notifier);
  return GameNotifier(
    gameSaveRepository,
    puzzleRecordRepository,
    gameSettings,
  );
});

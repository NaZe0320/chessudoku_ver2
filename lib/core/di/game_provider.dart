import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../presentation/notifiers/game_notifier.dart';
import '../../presentation/states/game_state.dart';
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

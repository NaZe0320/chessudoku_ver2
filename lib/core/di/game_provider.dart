import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/notifiers/game_notifier.dart';
import '../../domain/states/game_state.dart';
import '../di/providers.dart';

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final gameSaveRepository = ref.watch(gameSaveRepositoryProvider);
  return GameNotifier(gameSaveRepository);
});

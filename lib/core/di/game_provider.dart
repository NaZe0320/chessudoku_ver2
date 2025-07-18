import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/notifiers/game_notifier.dart';
import '../../domain/states/game_state.dart';

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

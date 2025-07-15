import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/domain/notifiers/game_notifier.dart';
import 'package:chessudoku/domain/states/game_state.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  // 실제 초기값은 화면에서 주입하거나, 여기서 임시로 생성할 수 있음
  return GameNotifier(
    const GameState(
      gameId: '',
      board: [],
    ),
  );
});

import 'dart:async';
import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/domain/states/game_state.dart';

class GameNotifier extends BaseNotifier<GameIntent, GameState> {
  Timer? _timer;

  GameNotifier() : super(const GameState());

  @override
  void onIntent(GameIntent intent) {
    switch (intent) {
      case SelectNumberIntent():
        _handleSelectNumber(intent.number);
      case ClearSelectionIntent():
        _handleClearSelection();
      case StartTimerIntent():
        _handleStartTimer();
      case PauseTimerIntent():
        _handlePauseTimer();
      case ResetTimerIntent():
        _handleResetTimer();
    }
  }

  void _handleSelectNumber(int number) {
    final newSelected = Set<int>.from(state.selectedNumbers);
    if (newSelected.contains(number)) {
      newSelected.remove(number);
    } else {
      newSelected.add(number);
    }
    state = state.copyWith(selectedNumbers: newSelected);
  }

  void _handleClearSelection() {
    state = state.copyWith(selectedNumbers: {});
  }

  void _handleStartTimer() {
    if (!state.isTimerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      });
      state = state.copyWith(isTimerRunning: true);
    }
  }

  void _handlePauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isTimerRunning: false);
  }

  void _handleResetTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      elapsedSeconds: 0,
      isTimerRunning: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

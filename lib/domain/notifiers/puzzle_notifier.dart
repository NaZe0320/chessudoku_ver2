import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleNotifier extends StateNotifier<PuzzleState> {
  PuzzleNotifier() : super(const PuzzleState());

  void changeDifficulty(Difficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }
}

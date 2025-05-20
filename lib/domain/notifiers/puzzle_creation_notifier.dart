import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/core/utils/chess_sudoku_generator.dart';
import 'package:chessudoku/domain/enums/creation_status.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/intents/puzzle_creation_intent.dart';
import 'package:chessudoku/domain/states/puzzle_creation_state.dart';

class PuzzleCreationNotifier
    extends BaseNotifier<PuzzleCreationIntent, PuzzleCreationState> {
  final ChessSudokuGenerator _generator = ChessSudokuGenerator();

  PuzzleCreationNotifier() : super(PuzzleCreationState());

  @override
  void onIntent(PuzzleCreationIntent intent) {
    switch (intent) {
      case CreatePuzzleIntent(:final difficulty):
        _createPuzzle(difficulty);
        break;
      case SelectDifficultyIntent(:final selectedDifficulty):
        _selectDifficulty(selectedDifficulty);
        break;
    }
  }

  void _selectDifficulty(Difficulty selectedDifficulty) {
    state = state.copyWith(selectedDifficulty: selectedDifficulty);
  }

  Future<void> _createPuzzle(Difficulty difficulty) async {
    state = state.copyWith(status: CreationStatus.loading);

    try {
      final board = await Future(() => _generator.generateBoard(difficulty));
      state = state.copyWith(
        status: CreationStatus.success,
        generatedBoard: board,
      );
    } catch (error) {
      state = state.copyWith(
        status: CreationStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}

import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/game_board.dart';

class GamePreparationState {
  final bool isPreparing;
  final bool isReady;
  final String? error;
  final GameBoard? preparedBoard;
  final String? puzzleId;
  final Difficulty? difficulty;

  const GamePreparationState({
    this.isPreparing = false,
    this.isReady = false,
    this.error,
    this.preparedBoard,
    this.puzzleId,
    this.difficulty,
  });

  GamePreparationState copyWith({
    bool? isPreparing,
    bool? isReady,
    String? error,
    GameBoard? preparedBoard,
    String? puzzleId,
    Difficulty? difficulty,
  }) {
    return GamePreparationState(
      isPreparing: isPreparing ?? this.isPreparing,
      isReady: isReady ?? this.isReady,
      error: error,
      preparedBoard: preparedBoard,
      puzzleId: puzzleId,
      difficulty: difficulty,
    );
  }
}

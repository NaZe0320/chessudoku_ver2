import 'package:chessudoku/domain/enums/difficulty.dart';

class PuzzleState {
  final Difficulty difficulty;

  const PuzzleState({this.difficulty = Difficulty.easy});

  PuzzleState copyWith({Difficulty? difficulty}) {
    return PuzzleState(difficulty: difficulty ?? this.difficulty);
  }
}

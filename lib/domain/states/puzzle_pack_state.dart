import 'package:chessudoku/data/models/puzzle_pack.dart';

class PuzzlePackState {
  final List<PuzzlePack> puzzlePacks;
  final bool isLoading;
  final String? errorMessage;

  const PuzzlePackState({
    this.puzzlePacks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PuzzlePackState copyWith({
    List<PuzzlePack>? puzzlePacks,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PuzzlePackState(
      puzzlePacks: puzzlePacks ?? this.puzzlePacks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

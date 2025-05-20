import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/creation_status.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class PuzzleCreationState {
  final CreationStatus status;
  final Difficulty selectedDifficulty;
  final List<List<CellContent>>? generatedBoard;
  final String? _errorMessage;

  PuzzleCreationState({
    this.status = CreationStatus.initial,
    this.selectedDifficulty = Difficulty.easy,
    this.generatedBoard,
    String? errorMessage,
  }) : _errorMessage = errorMessage;

  PuzzleCreationState copyWith({
    CreationStatus? status,
    Difficulty? selectedDifficulty,
    List<List<CellContent>>? generatedBoard,
    String? errorMessage,
  }) {
    return PuzzleCreationState(
      status: status ?? this.status,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      generatedBoard: generatedBoard ?? this.generatedBoard,
      errorMessage: errorMessage ?? _errorMessage,
    );
  }
}

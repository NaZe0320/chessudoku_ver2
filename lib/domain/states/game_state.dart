import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class GameState {
  final String gameId;
  final Difficulty difficulty;
  final List<List<CellContent>> board;
  final int? selectedRow;
  final int? selectedCol;
  final bool isCompleted;
  final Duration elapsedTime;
  final int boardSize;
  final bool isPaused;

  const GameState({
    required this.gameId,
    this.difficulty = Difficulty.easy,
    required this.board,
    this.selectedRow,
    this.selectedCol,
    this.isCompleted = false,
    this.elapsedTime = Duration.zero,
    this.isPaused = false,
    this.boardSize = 9,
  });

  // 새 상태 반환 (불변성 유지)
  GameState copyWith({
    String? gameId,
    Difficulty? difficulty,
    List<List<CellContent>>? board,
    int? selectedRow,
    int? selectedCol,
    bool? isCompleted,
    Duration? elapsedTime,
    int? boardSize,
    bool? isPaused,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      difficulty: difficulty ?? this.difficulty,
      board: board ?? this.board,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      isCompleted: isCompleted ?? this.isCompleted,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      boardSize: boardSize ?? this.boardSize,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

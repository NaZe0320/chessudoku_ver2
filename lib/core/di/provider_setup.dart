import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/domain/notifiers/game_notifier.dart';
import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 초기 빈 보드를 생성하는 함수
List<List<CellContent>> _createEmptyBoard(int size) {
  return List.generate(
    size,
    (i) => List.generate(
      size,
      (j) => const CellContent(),
    ),
  );
}

/// 게임 상태 Provider
final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) {
    // 초기 게임 상태 생성
    final initialState = GameState(
      gameId: 'initial',
      difficulty: Difficulty.easy,
      board: _createEmptyBoard(9),
      selectedRow: null,
      selectedCol: null,
      isCompleted: false,
      elapsedTime: Duration.zero,
      isPaused: false,
      boardSize: 9,
    );

    return GameNotifier(initialState);
  },
);

/// 현재 선택된 셀 Provider (편의를 위한 computed provider)
final selectedCellProvider = Provider<({int? row, int? col})?>(
  (ref) {
    final gameState = ref.watch(gameNotifierProvider);
    if (gameState.selectedRow != null && gameState.selectedCol != null) {
      return (row: gameState.selectedRow, col: gameState.selectedCol);
    }
    return null;
  },
);

/// 게임 완료 상태 Provider
final isGameCompletedProvider = Provider<bool>(
  (ref) => ref.watch(gameNotifierProvider).isCompleted,
);

/// 게임 일시정지 상태 Provider
final isGamePausedProvider = Provider<bool>(
  (ref) => ref.watch(gameNotifierProvider).isPaused,
);

/// 경과 시간 Provider
final elapsedTimeProvider = Provider<Duration>(
  (ref) => ref.watch(gameNotifierProvider).elapsedTime,
);

/// 현재 난이도 Provider
final currentDifficultyProvider = Provider<Difficulty>(
  (ref) => ref.watch(gameNotifierProvider).difficulty,
);

/// 특정 셀의 내용을 가져오는 Provider
final cellContentProvider = Provider.family<CellContent?, ({int row, int col})>(
  (ref, position) {
    final gameState = ref.watch(gameNotifierProvider);
    if (position.row >= 0 &&
        position.row < gameState.boardSize &&
        position.col >= 0 &&
        position.col < gameState.boardSize) {
      return gameState.board[position.row][position.col];
    }
    return null;
  },
);

/// 보드 전체를 가져오는 Provider
final boardProvider = Provider<List<List<CellContent>>>(
  (ref) => ref.watch(gameNotifierProvider).board,
);

/// 게임 통계 Provider
final gameStatsProvider = Provider<
    ({
      int filledCells,
      int emptyCells,
      int totalCells,
      double completionPercentage,
    })>(
  (ref) {
    final board = ref.watch(boardProvider);
    int filledCells = 0;
    int totalCells = 0;

    for (final row in board) {
      for (final cell in row) {
        totalCells++;
        if (cell.hasNumber) {
          filledCells++;
        }
      }
    }

    final emptyCells = totalCells - filledCells;
    final completionPercentage =
        totalCells > 0 ? (filledCells / totalCells) * 100 : 0.0;

    return (
      filledCells: filledCells,
      emptyCells: emptyCells,
      totalCells: totalCells,
      completionPercentage: completionPercentage,
    );
  },
);

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'sudoku_cell.dart';

class SudokuBoard extends HookConsumerWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width - 32; // 좌우 패딩 16씩 제외
    final maxHeight = screenSize.height * 0.6; // 세로 화면 길이의 0.6배
    final boardSize = maxWidth < maxHeight ? maxWidth : maxHeight;

    // currentBoard가 없으면 빈 화면 표시
    if (gameState.currentBoard == null) {
      return Center(
        child: Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.neutral400.withValues(alpha: 1.0),
              width: 1,
            ),
            color: AppColors.surface,
          ),
          child: const Center(
            child: Text('게임 보드를 불러오는 중...'),
          ),
        ),
      );
    }

    final currentBoard = gameState.currentBoard!;

    return Center(
      child: Container(
        width: boardSize,
        height: boardSize,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neutral400.withValues(alpha: 1.0),
            width: 1,
          ),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  final position = Position(row: row, col: col);
                  final cellContent =
                      currentBoard.board.getCellContent(position);
                  final isSelected = currentBoard.selectedCell == position;
                  final isHighlighted =
                      currentBoard.highlightedCells.contains(position);
                  final hasError = currentBoard.errorCells.contains(position);

                  return Expanded(
                    child: SudokuCell(
                      row: row,
                      col: col,
                      cellContent: cellContent,
                      isSelected: isSelected,
                      isHighlighted: isHighlighted,
                      hasError: hasError,
                      onTap: () {
                        gameNotifier.handleIntent(SelectCellIntent(position));
                      },
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

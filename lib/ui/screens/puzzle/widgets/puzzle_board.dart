import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_cell.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleBoard extends ConsumerWidget {
  const PuzzleBoard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);
    final screenSize = MediaQuery.of(context).size;
    final boardSize = puzzleState.boardSize;

    // 화면에 맞게 보드 크기 조정
    final widthSize = screenSize.width - 32;
    final heightSize = screenSize.height * 0.6;
    final boardLength = widthSize < heightSize ? widthSize : heightSize;
    final cellSize = boardLength / boardSize;

    return Container(
      width: boardLength,
      height: boardLength,
      decoration: BoxDecoration(
        color: AppColors.neutral200,
        border: Border.all(
          color: AppColors.neutral600,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral700.withAlpha(10),
            blurRadius: 3,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: puzzleState.board.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boardSize,
              ),
              itemCount: boardSize * boardSize,
              itemBuilder: (context, index) {
                final row = index ~/ boardSize;
                final col = index % boardSize;

                return PuzzleCell(
                  row: row,
                  col: col,
                  cellSize: cellSize,
                  boardSize: boardSize,
                );
              },
            ),
    );
  }
}

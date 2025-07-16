import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'sudoku_cell.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width - 32; // 좌우 패딩 16씩 제외
    final maxHeight = screenSize.height * 0.6; // 세로 화면 길이의 0.6배
    final boardSize = maxWidth < maxHeight ? maxWidth : maxHeight;

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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  return Expanded(
                    child: SudokuCell(
                      row: row,
                      col: col,
                      value: null,
                      isSelected: false,
                      onTap: () {
                        // TODO: 셀 선택 로직
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

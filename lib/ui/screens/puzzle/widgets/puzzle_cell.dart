import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleCell extends ConsumerWidget {
  final int row;
  final int col;
  final double cellSize;
  final int boardSize;

  const PuzzleCell({
    super.key,
    required this.row,
    required this.col,
    required this.cellSize,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);
    final intent = ref.read(puzzleIntentProvider);

    if (row >= puzzleState.board.length ||
        col >= puzzleState.board[row].length) {
      return Container(color: AppColors.neutral100);
    }

    final cell = puzzleState.board[row][col];
    final isSelected =
        puzzleState.selectedRow == row && puzzleState.selectedCol == col;

    // 3x3 박스 경계 처리
    final isRightBorder = (col + 1) % 3 == 0 && col < boardSize - 1;
    final isBottomBorder = (row + 1) % 3 == 0 && row < boardSize - 1;

    // 셀 배경색 결정
    Color cellColor;
    if (isSelected) {
      cellColor = AppColors.primaryLight.withAlpha(30);
    } else if (cell.isInitial) {
      cellColor = AppColors.neutral200;
    } else {
      cellColor = AppColors.neutral100;
    }

    return GestureDetector(
      onTap: () => intent.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(
            right: BorderSide(
              width: isRightBorder ? 1 : 0.5,
              color: AppColors.neutral700,
            ),
            bottom: BorderSide(
              width: isBottomBorder ? 1 : 0.5,
              color: AppColors.neutral700,
            ),
            top: BorderSide(
              width: row == 0 ? 1 : 0.5,
              color: AppColors.neutral700,
            ),
            left: BorderSide(
              width: col == 0 ? 1 : 0.5,
              color: AppColors.neutral700,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: _buildCellContent(cell, intent),
      ),
    );
  }

  Widget _buildCellContent(cell, intent) {
    // 체스 기물이 있는 경우
    if (cell.hasChessPiece) {
      return Text(
        intent.getChessPieceSymbol(cell.chessPiece!),
        style: TextStyle(
          fontSize: cellSize * 0.5,
          color: AppColors.neutral900,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // 숫자가 있는 경우
    if (cell.hasNumber) {
      return Text(
        cell.number.toString(),
        style: TextStyle(
          fontSize: cellSize * 0.5,
          fontWeight: cell.isInitial ? FontWeight.bold : FontWeight.normal,
          color: cell.isInitial ? AppColors.neutral900 : AppColors.primaryLight,
        ),
      );
    }

    // 메모가 있는 경우
    if (cell.hasNotes) {
      return _buildNotesGrid(cell);
    }

    // 빈 셀
    return const SizedBox();
  }

  Widget _buildNotesGrid(cell) {
    return GridView.builder(
      padding: EdgeInsets.all(cellSize * 0.05),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      itemBuilder: (context, index) {
        final number = index + 1;
        final hasNote = cell.hasNote(number);

        return hasNote
            ? Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: cellSize * 0.2,
                    color: AppColors.neutral700,
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }
}

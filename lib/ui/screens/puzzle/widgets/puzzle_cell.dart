import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
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
    final isRightBorder = (col + 1) % 3 == 0 && col <= boardSize - 1;
    final isBottomBorder = (row + 1) % 3 == 0 && row <= boardSize - 1;

    // 셀 배경색 결정
    Color cellColor;
    if (isSelected) {
      cellColor = AppColors.primaryLight.withAlpha(64);
    } else if (cell.isInitial) {
      cellColor = AppColors.neutral200;
    } else {
      cellColor = AppColors.neutral100;
    }

    // 오류 셀 표시
    final isError = puzzleState.errorCells.contains('$row,$col');

    // 오류가 있으면 빨간색 배경으로 표시
    if (isError) {
      cellColor = AppColors.error.withAlpha(70);
    }

    return GestureDetector(
      onTap: () => intent.selectCell(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(
            right: BorderSide(
              width: isRightBorder ? 2 : 0.5,
              color:
                  isRightBorder ? AppColors.neutral700 : AppColors.neutral400,
            ),
            bottom: BorderSide(
              width: isBottomBorder ? 2 : 0.5,
              color:
                  isBottomBorder ? AppColors.neutral700 : AppColors.neutral400,
            ),
            top: BorderSide(
              width: row == 0 ? 2 : 0.5,
              color: row == 0 ? AppColors.neutral700 : AppColors.neutral400,
            ),
            left: BorderSide(
              width: col == 0 ? 2 : 0.5,
              color: col == 0 ? AppColors.neutral700 : AppColors.neutral400,
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
        style: AppTextStyles.cellNumber(isInitial: cell.isInitial),
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
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          final hasNote = cell.hasNote(number);

          return hasNote
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    number.toString(),
                    style: AppTextStyles.cellNote,
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox();
        },
      ),
    );
  }
}

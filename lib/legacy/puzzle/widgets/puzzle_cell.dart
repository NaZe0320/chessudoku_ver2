import 'package:chessudoku/legacy/puzzle_provider.dart';
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

    if (row >= puzzleState.board.length || col >= puzzleState.board[row].length) {
      return Container(color: AppColors2.neutral100);
    }

    final cell = puzzleState.board[row][col];
    final isSelected = puzzleState.selectedRow == row && puzzleState.selectedCol == col;

    // 3x3 박스 경계 처리
    const borderSide = BorderSide(color: AppColors2.neutral400, width: 0.5);
    const boldBorderSide = BorderSide(color: AppColors2.neutral400, width: 2.0);

    // 셀 배경색 결정
    Color cellColor;
    if (isSelected) {
      cellColor = AppColors2.primaryLight.withAlpha(64);
    } else if (cell.isInitial) {
      cellColor = AppColors2.neutral200;
    } else {
      cellColor = AppColors2.neutral100;
    }

    // 오류 셀 표시
    final isError = puzzleState.errorCells.contains('$row,$col');

    // 오류가 있으면 빨간색 배경으로 표시
    if (isError) {
      cellColor = AppColors2.error.withAlpha(70);
    }

    return GestureDetector(
      onTap: () => intent.selectCell(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(
            top: row % 3 == 0 ? boldBorderSide : borderSide,
            left: col % 3 == 0 ? boldBorderSide : borderSide,
            right: col == 8 ? boldBorderSide : BorderSide.none,
            bottom: row == 8 ? boldBorderSide : BorderSide.none,
          ),
        ),
        alignment: Alignment.center,
        child: _buildCellContent(cell),
      ),
    );
  }

  Widget _buildCellContent(cell) {
    // 체스 기물이 있는 경우
    if (cell.hasChessPiece) {
      return Text(
        cell.chessPiece!.symbol,
        style: TextStyle(
          fontSize: cellSize * 0.5,
          color: AppColors2.neutral900,
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
    return GridView.builder(
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
    );
  }
}

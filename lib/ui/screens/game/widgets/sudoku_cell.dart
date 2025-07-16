import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';

class SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final int? value;
  final bool isSelected;
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: _shouldShowThickBorder(row, true)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(row, true) ? 1.0 : 0.5,
            ),
            bottom: BorderSide(
              color: _shouldShowThickBorder(row + 1, true)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(row + 1, true) ? 1.0 : 0.5,
            ),
            left: BorderSide(
              color: _shouldShowThickBorder(col, false)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(col, false) ? 1.0 : 0.5,
            ),
            right: BorderSide(
              color: _shouldShowThickBorder(col + 1, false)
                  ? AppColors.neutral400.withValues(alpha: 0.8)
                  : AppColors.neutral400.withValues(alpha: 0.6),
              width: _shouldShowThickBorder(col + 1, false) ? 1.0 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: value != null
              ? Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  bool _shouldShowThickBorder(int index, bool isRow) {
    return index % 3 == 0;
  }
}

import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class FilterChipWidget<T> extends StatelessWidget {
  final FilterOption<T> option;
  final VoidCallback onTap;
  final EdgeInsets? padding;
  final double? borderRadius;

  const FilterChipWidget({
    Key? key,
    required this.option,
    required this.onTap,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = option.isSelected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(borderRadius ?? 20.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.0,
          ),
        ),
        child: Text(
          option.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

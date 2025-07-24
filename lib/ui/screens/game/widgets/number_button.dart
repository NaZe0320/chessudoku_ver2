import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';

class NumberButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const NumberButton({
    super.key,
    required this.text,
    this.icon,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor:
            !isDisabled ? AppColors.primary.withValues(alpha: 0.2) : null,
        highlightColor:
            !isDisabled ? AppColors.primary.withValues(alpha: 0.1) : null,
        child: Ink(
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.neutral100
                : (isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.neutral50),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDisabled
                  ? AppColors.neutral200
                  : (isSelected ? AppColors.primary : AppColors.neutral300),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: icon != null
                  ? Icon(
                      icon,
                      color: isDisabled
                          ? AppColors.neutral400
                          : (isSelected
                              ? AppColors.primary
                              : AppColors.neutral700),
                      size: 20,
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: isDisabled
                            ? AppColors.neutral400
                            : (isSelected
                                ? AppColors.primary
                                : AppColors.neutral800),
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

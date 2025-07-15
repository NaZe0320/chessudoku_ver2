import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../theme/color_palette.dart';
import '../../theme/dimensions.dart';
import '../../theme/typography.dart';

class DifficultyButton extends HookConsumerWidget {
  final String title;
  final String timeRange;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const DifficultyButton({
    super.key,
    required this.title,
    required this.timeRange,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? borderColor : borderColor.withOpacity(0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeRange,
              style: AppTypography.body.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

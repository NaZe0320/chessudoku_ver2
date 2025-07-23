import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class DayProgressButton extends StatelessWidget {
  final String day;
  final bool isCompleted;
  final VoidCallback? onTap;

  const DayProgressButton({
    super.key,
    required this.day,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green
                  : Colors.white.withValues(alpha: 0.3),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

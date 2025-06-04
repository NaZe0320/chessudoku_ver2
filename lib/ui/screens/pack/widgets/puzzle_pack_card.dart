import 'package:flutter/material.dart';
import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';

class PuzzlePackCard extends StatelessWidget {
  final PuzzlePack pack;
  final VoidCallback? onTap;

  const PuzzlePackCard({
    super.key,
    required this.pack,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이콘
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 32,
                          color: _getIconColor(),
                        ),
                      ),
                    ),
                  ],
                ),

                // 팩 이름
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 퍼즐 수
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${pack.totalPuzzles} 퍼즐',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pack.difficulty.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 프리미엄 배지
            if (pack.isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '프리미엄',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 아이콘 배경 색상
  Color _getIconBackgroundColor() {
    switch (pack.difficulty) {
      case Difficulty.easy:
        return AppColors.success.withValues(alpha: 0.1);
      case Difficulty.medium:
        return AppColors.info.withValues(alpha: 0.1);
      case Difficulty.hard:
        return AppColors.warning.withValues(alpha: 0.1);
      case Difficulty.expert:
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
    }
  }

  /// 아이콘 색상
  Color _getIconColor() {
    switch (pack.difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.info;
      case Difficulty.hard:
        return AppColors.warning;
      case Difficulty.expert:
        return const Color(0xFFEF4444);
    }
  }

  /// 난이도별 색상
  Color _getDifficultyColor() {
    switch (pack.difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.info;
      case Difficulty.hard:
        return AppColors.warning;
      case Difficulty.expert:
        return const Color(0xFFEF4444);
    }
  }
}

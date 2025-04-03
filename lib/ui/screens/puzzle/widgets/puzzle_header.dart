import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleHeader extends ConsumerWidget {
  const PuzzleHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);

    return Column(
      children: [
        const SizedBox(height: 20),
        // 현재 난이도 표시
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withAlpha(10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryLight.withAlpha(30)),
          ),
          child: Text(
            '현재 난이도: ${puzzleState.difficulty.label}',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
        ),

        // 게임 완료 메시지
        if (puzzleState.isCompleted)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '축하합니다! 퍼즐을 완료했습니다!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}

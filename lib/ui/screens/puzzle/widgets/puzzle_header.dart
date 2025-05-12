import 'package:chessudoku/core/di/puzzle_provider.dart';
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
        const SizedBox(height: 12),
        // 현재 난이도 표시
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors2.primary.withAlpha(26),
                AppColors2.primaryLight.withAlpha(13),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors2.primary.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: AppColors2.primary.withAlpha(51),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                color: AppColors2.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '난이도: ${puzzleState.difficulty.label}',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors2.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // if (puzzleState.isCompleted)
        //   Container(
        //     margin: const EdgeInsets.symmetric(vertical: 8),
        //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [
        //           AppColors.success.withAlpha(26),
        //           AppColors.accent1.withAlpha(26),
        //         ],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        //       borderRadius: BorderRadius.circular(12),
        //       boxShadow: [
        //         BoxShadow(
        //           color: AppColors.success.withAlpha(26),
        //           blurRadius: 4,
        //           offset: const Offset(0, 1),
        //         ),
        //       ],
        //       border: Border.all(
        //         color: AppColors.success.withAlpha(77),
        //         width: 1,
        //       ),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         const Icon(
        //           Icons.check_circle_rounded,
        //           color: AppColors.success,
        //           size: 18,
        //         ),
        //         const SizedBox(width: 8),
        //         Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               '축하합니다!',
        //               style: AppTextStyles.subtitle1.copyWith(
        //                 color: AppColors.success,
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 14,
        //               ),
        //             ),
        //             const SizedBox(height: 2),
        //             Text(
        //               '퍼즐을 성공적으로 완료했습니다.',
        //               style: AppTextStyles.bodyMedium.copyWith(
        //                 color: AppColors.success,
        //                 fontSize: 12,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}

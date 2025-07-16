import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DifficultyButtonsWidget extends HookConsumerWidget {
  const DifficultyButtonsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 퍼즐 플레이 섹션 헤더
        Row(
          children: [
            const Icon(
              Icons.flash_on,
              color: AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              translate('puzzle_play', '퍼즐 플레이'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          translate('improve_skill_description', '난이도를 선택하여 바로 시작할 수 있는 랜덤 퍼즐'),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textWhite,
          ),
        ),

        const SizedBox(height: 16),

        // 난이도 버튼들
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textWhite.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    translate('easy', '쉬움'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    translate('normal', '보통'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

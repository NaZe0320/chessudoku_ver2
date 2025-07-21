import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:chessudoku/ui/theme/dimensions.dart';

class GameCompletionDialog extends HookConsumerWidget {
  final int elapsedSeconds;
  final VoidCallback? onNewGame;
  final VoidCallback? onContinue;

  const GameCompletionDialog({
    super.key,
    required this.elapsedSeconds,
    this.onNewGame,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);

    String formatTime(int seconds) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final remainingSeconds = seconds % 60;

      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      } else {
        return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      }
    }

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 완료 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: Spacing.space4),

            // 제목
            Text(
              '축하합니다!',
              style: AppTypography.heading1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.space2),

            Text(
              '퍼즐을 완성했습니다!',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.space6),

            // 완료 시간
            Container(
              padding: const EdgeInsets.all(Spacing.space4),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.space2),
                  Text(
                    '완료 시간: ${formatTime(elapsedSeconds)}',
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.space6),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      notifier.handleIntent(const HideCompletionDialogIntent());
                      onContinue?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.space4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      ),
                    ),
                    child: Text(
                      '계속하기',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.space4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      notifier.handleIntent(const HideCompletionDialogIntent());
                      onNewGame?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.space4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      ),
                    ),
                    child: Text(
                      '새 게임',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

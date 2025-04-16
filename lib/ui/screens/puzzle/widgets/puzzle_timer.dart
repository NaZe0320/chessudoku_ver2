import 'package:chessudoku/core/di/puzzle_provider.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleTimer extends ConsumerWidget {
  const PuzzleTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);
    final puzzleIntent = ref.read(puzzleIntentProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 16,
            color: AppColors.neutral100,
          ),
          const SizedBox(width: 4),
          Text(
            puzzleState.formattedTime,
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.neutral100,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (puzzleState.isTimerRunning) {
                  puzzleIntent.pauseTimer();
                } else {
                  puzzleIntent.resumeTimer();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  puzzleState.isTimerRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 16,
                  color: AppColors.neutral100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chessudoku/core/di/providers.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, size: 18, color: AppColors.neutral100),
          const SizedBox(width: 4),
          Text(
            puzzleState.formattedTime,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              puzzleState.isTimerRunning ? Icons.pause : Icons.play_arrow,
              size: 18,
              color: AppColors.neutral100,
            ),
            onPressed: () {
              if (puzzleState.isTimerRunning) {
                puzzleIntent.pauseTimer();
              } else {
                puzzleIntent.resumeTimer();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/common/widgets/app_button.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleControls extends ConsumerWidget {
  const PuzzleControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);
    final intent = ref.read(puzzleIntentProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: DropdownButton<Difficulty>(
              value: puzzleState.difficulty,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              items: Difficulty.values.map((difficulty) {
                return DropdownMenuItem<Difficulty>(
                  value: difficulty,
                  child: Text(
                    difficulty.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (Difficulty? newValue) {
                if (newValue != null) {
                  intent.changeDifficulty(newValue);
                }
              },
            ),
          ),
          AppButton(
            text: '새 게임',
            onTap: () => intent.initializeGame(),
            type: ButtonType.success,
            size: ButtonSize.medium,
            prefixIcon:
                const Icon(Icons.add, color: AppColors.neutral100, size: 18),
          ),
          AppButton(
            text: '재시작',
            onTap: () => intent.restartGame(),
            type: ButtonType.warning,
            size: ButtonSize.medium,
            prefixIcon: const Icon(Icons.refresh,
                color: AppColors.neutral100, size: 18),
          ),
        ],
      ),
    );
  }
}

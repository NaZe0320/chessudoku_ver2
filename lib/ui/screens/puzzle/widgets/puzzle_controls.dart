import 'package:chessudoku/core/di/providers.dart';
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
      child: Column(
        children: [
          // 히스토리 컨트롤 행
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 되돌리기 버튼
              IconButton(
                onPressed:
                    puzzleState.canUndo ? () => intent.undoAction() : null,
                icon: const Icon(Icons.undo),
                color: puzzleState.canUndo
                    ? AppColors.primary
                    : AppColors.neutral400,
                tooltip: '되돌리기',
              ),

              // 메모 모드 토글 버튼
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () => intent.toggleNoteMode(),
                  icon: Icon(
                    Icons.edit_note,
                    color: puzzleState.isNoteMode
                        ? AppColors.neutral100
                        : AppColors.primary,
                  ),
                  label: Text(
                    '메모 모드',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: puzzleState.isNoteMode
                          ? AppColors.neutral100
                          : AppColors.primary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: puzzleState.isNoteMode
                        ? AppColors.primary
                        : AppColors.neutral200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),

              // 다시 실행 버튼
              IconButton(
                onPressed:
                    puzzleState.canRedo ? () => intent.redoAction() : null,
                icon: const Icon(Icons.redo),
                color: puzzleState.canRedo
                    ? AppColors.primary
                    : AppColors.neutral400,
                tooltip: '다시 실행',
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

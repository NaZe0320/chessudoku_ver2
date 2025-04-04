import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/common/widgets/app_neomorphic_button.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 되돌리기 버튼
              _buildIconButton(
                icon: Icons.undo,
                onTap: puzzleState.canUndo ? () => intent.undoAction() : null,
                isEnabled: puzzleState.canUndo,
                tooltip: '되돌리기',
              ),

              // 메모 모드 토글 버튼
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: AppNeomorphicButton(
                  text: '메모 모드',
                  prefixIcon: Icon(
                    Icons.edit_note,
                    color: puzzleState.isNoteMode
                        ? AppColors.primary
                        : AppColors.neutral700,
                    size: 18,
                  ),
                  onTap: () => intent.toggleNoteMode(),
                  type: NeomorphicButtonType.primary,
                  size: NeomorphicButtonSize.medium,
                  borderRadius: 16,
                  isActive: puzzleState.isNoteMode,
                ),
              ),

              // 다시 실행 버튼
              _buildIconButton(
                icon: Icons.redo,
                onTap: puzzleState.canRedo ? () => intent.redoAction() : null,
                isEnabled: puzzleState.canRedo,
                tooltip: '다시 실행',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool isEnabled = true,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neutral300,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Icon(
                  icon,
                  color: isEnabled ? AppColors.primary : AppColors.neutral500,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

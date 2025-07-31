import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class GameSelectionDialog extends StatelessWidget {
  final String title;
  final String message;
  final Difficulty difficulty;
  final VoidCallback? onContinueGame;
  final VoidCallback? onNewGame;
  final VoidCallback? onCancel;

  const GameSelectionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.difficulty,
    this.onContinueGame,
    this.onNewGame,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Text(
              title,
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 메시지
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 난이도 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getDifficultyColor(difficulty).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getDifficultyText(difficulty),
                style: AppTypography.body.copyWith(
                  color: _getDifficultyColor(difficulty),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 버튼들
            Column(
              children: [
                // 이어서 하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onContinueGame?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '이어서 하기',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 새로 하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNewGame?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: AppColors.neutral300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '새로 하기',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 취소 버튼
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    child: Text(
                      '취소',
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.textSecondary,
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

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '쉬움';
      case Difficulty.medium:
        return '보통';
      case Difficulty.hard:
        return '어려움';
      case Difficulty.expert:
        return '전문가';
    }
  }

  /// 게임 선택 다이얼로그 표시 (정적 메서드)
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required Difficulty difficulty,
    VoidCallback? onContinueGame,
    VoidCallback? onNewGame,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return GameSelectionDialog(
          title: title,
          message: message,
          difficulty: difficulty,
          onContinueGame: onContinueGame,
          onNewGame: onNewGame,
          onCancel: onCancel,
        );
      },
    );
  }
}

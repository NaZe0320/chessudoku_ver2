import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

class GameSelectionDialog extends StatelessWidget {
  final String title;
  final String message;
  final Difficulty difficulty;
  final String? elapsedTime;
  final VoidCallback? onContinueGame;
  final VoidCallback? onNewGame;
  final VoidCallback? onCancel;

  const GameSelectionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.difficulty,
    this.elapsedTime,
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
            const SizedBox(height: 20),

            // 게임 정보 (난이도 + 진행시간)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 난이도 표시
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: difficulty.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: difficulty.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    difficulty.label,
                    style: AppTypography.body.copyWith(
                      color: difficulty.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // 진행시간 표시
                if (elapsedTime != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.neutral300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          elapsedTime!,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // 버튼들 (가로 배치)
            Row(
              children: [
                // 이어서 하기 버튼
                Expanded(
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
                const SizedBox(width: 12),

                // 새로 하기 버튼
                Expanded(
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 게임 선택 다이얼로그 표시 (정적 메서드)
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required Difficulty difficulty,
    String? elapsedTime,
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
          elapsedTime: elapsedTime,
          onContinueGame: onContinueGame,
          onNewGame: onNewGame,
          onCancel: onCancel,
        );
      },
    );
  }
}

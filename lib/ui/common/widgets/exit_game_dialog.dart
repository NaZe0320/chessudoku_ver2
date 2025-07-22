import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/typography.dart';

class ExitGameDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String exitText;
  final VoidCallback onCancel;
  final VoidCallback onExit;

  const ExitGameDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.exitText,
    required this.onCancel,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8.0,
      backgroundColor: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: const Icon(
                Icons.exit_to_app,
                color: AppColors.textWhite,
                size: 32.0,
              ),
            ),
            const SizedBox(height: 20.0),

            // 제목
            Text(
              title,
              style: AppTypography.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),

            // 메시지
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: const BorderSide(color: AppColors.neutral300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: AppTypography.buttonText.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onExit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      exitText,
                      style: AppTypography.buttonText,
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

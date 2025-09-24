import 'package:flutter/material.dart';
import 'package:chessudoku/presentation/theme/color_palette.dart';

class WithdrawDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String withdrawText;
  final VoidCallback onCancel;
  final VoidCallback onWithdraw;

  const WithdrawDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.withdrawText,
    required this.onCancel,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 아이콘 (메인 테마 스타일)
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.error,
                size: 40.0,
              ),
            ),
            const SizedBox(height: 24.0),

            // 제목
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),

            // 메시지
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),

            // 버튼들 (글래스모피즘 스타일)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.0),
                        onTap: onCancel,
                        child: Center(
                          child: Text(
                            cancelText,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.0),
                        onTap: onWithdraw,
                        child: Center(
                          child: Text(
                            withdrawText,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

  /// 탈퇴 확인 다이얼로그 표시 정적 메서드
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String cancelText,
    required String withdrawText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        withdrawText: withdrawText,
        onCancel: () => Navigator.pop(context, false),
        onWithdraw: () => Navigator.pop(context, true),
      ),
    );
  }
}

import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 로딩 다이얼로그
///
/// 퍼즐 생성 중이나 긴 작업 시 표시되는 로딩 다이얼로그입니다.
class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
    this.message = '로딩 중...',
  });

  /// 표시할 메시지
  final String message;

  /// 다이얼로그 표시
  ///
  /// [context]: 빌드 컨텍스트
  /// [message]: 표시할 메시지 (기본값: '로딩 중...')
  static Future<void> show(BuildContext context, {String message = '로딩 중...'}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 사용자가 바깥을 눌러 닫을 수 없음
      builder: (context) => LoadingDialog(message: message),
    );
  }

  /// 다이얼로그 닫기
  ///
  /// [context]: 빌드 컨텍스트
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral700.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

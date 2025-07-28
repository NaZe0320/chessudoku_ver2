import 'package:flutter/material.dart';

/// 오프라인 상태 안내 다이얼로그
class OfflineDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const OfflineDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction!();
            },
            child: Text(actionText!),
          ),
      ],
    );
  }
}

/// 오프라인 다이얼로그 표시 헬퍼 함수
class OfflineDialogHelper {
  /// 새 퍼즐 시작 시 오프라인 안내
  static void showNewPuzzleOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineDialog(
        title: '온라인 연결 필요',
        message: '새 퍼즐은 온라인에서만 다운로드 가능합니다.\n인터넷 연결을 확인해주세요.',
        actionText: '설정으로 이동',
        onAction: null, // TODO: 설정 화면으로 이동
      ),
    );
  }

  /// 최초 실행 시 오프라인 안내
  static void showFirstLaunchOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OfflineDialog(
        title: '온라인 연결 필요',
        message: '앱을 처음 사용하기 위해서는 온라인 연결이 필요합니다.\n인터넷 연결을 확인한 후 앱을 다시 시작해주세요.',
        actionText: '앱 종료',
        onAction: null, // TODO: 앱 종료 로직
      ),
    );
  }

  /// 일반 오프라인 안내
  static void showGeneralOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineDialog(
        title: '오프라인 모드',
        message: '오프라인 모드입니다.\n일부 기능이 제한되며, 진행 상황은 나중에 동기화됩니다.',
      ),
    );
  }
}

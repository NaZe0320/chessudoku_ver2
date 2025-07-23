import 'package:flutter/material.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';

enum ButtonType {
  toggle, // 메모 버튼 - 활성화/비활성화 상태
  action, // 되돌리기/다시 실행 버튼 - 기본/비활성화 상태
}

class GameActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isActive;
  final ButtonType buttonType;

  const GameActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.isActive = false,
    this.buttonType = ButtonType.action,
  });

  @override
  Widget build(BuildContext context) {
    // 모든 버튼을 동일한 로직으로 처리
    final isEnabled = isActive;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? Colors.grey[300]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? Colors.grey[700] : Colors.grey[400],
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: isEnabled ? Colors.grey[800] : Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

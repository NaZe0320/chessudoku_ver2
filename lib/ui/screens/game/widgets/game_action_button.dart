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
    final isEnabled = buttonType == ButtonType.toggle ? true : isActive;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(),
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
              color: _getIconColor(),
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (buttonType == ButtonType.toggle) {
      // 메모 버튼: 활성화 시 primary 색상, 비활성화 시 기본 색상
      return isActive
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.grey[50]!;
    } else {
      // 되돌리기/다시 실행 버튼: 활성화 시 기본 색상, 비활성화 시 회색
      return isActive ? Colors.grey[50]! : Colors.grey[200]!;
    }
  }

  Color _getBorderColor() {
    if (buttonType == ButtonType.toggle) {
      // 메모 버튼: 활성화 시 primary 색상, 비활성화 시 회색
      return isActive ? AppColors.primary : Colors.grey[300]!;
    } else {
      // 되돌리기/다시 실행 버튼: 활성화 시 기본 색상, 비활성화 시 연한 회색
      return isActive ? Colors.grey[300]! : Colors.grey[400]!;
    }
  }

  Color _getIconColor() {
    if (buttonType == ButtonType.toggle) {
      // 메모 버튼: 활성화 시 primary 색상, 비활성화 시 회색
      return isActive ? AppColors.primary : Colors.grey[700]!;
    } else {
      // 되돌리기/다시 실행 버튼: 활성화 시 기본 색상, 비활성화 시 연한 회색
      return isActive ? Colors.grey[700]! : Colors.grey[500]!;
    }
  }

  Color _getTextColor() {
    if (buttonType == ButtonType.toggle) {
      // 메모 버튼: 활성화 시 primary 색상, 비활성화 시 회색
      return isActive ? AppColors.primary : Colors.grey[800]!;
    } else {
      // 되돌리기/다시 실행 버튼: 활성화 시 기본 색상, 비활성화 시 연한 회색
      return isActive ? Colors.grey[800]! : Colors.grey[600]!;
    }
  }
}

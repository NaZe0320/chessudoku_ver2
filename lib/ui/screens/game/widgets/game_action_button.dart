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
  final bool isPaused;

  const GameActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.isActive = false,
    this.buttonType = ButtonType.action,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    // 메모 버튼은 메모 모드 상태를, 다른 버튼들은 활성화 상태를 사용
    final isMemoMode = buttonType == ButtonType.toggle ? isActive : false;
    final isActionAvailable =
        buttonType == ButtonType.action ? isActive : true; // 액션 버튼은 활성화 상태 확인
    final isButtonEnabled =
        !isPaused && isActionAvailable; // 일시정지가 아니고 액션이 가능할 때만 사용 가능

    // 메모 버튼: 메모 모드 상태와 일시정지 상태를 별도로 처리
    // 다른 버튼들: 활성화 상태와 일시정지 상태를 별도로 처리
    final isEnabled = isButtonEnabled;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isMemoMode
                  ? Colors.blue[50]
                  : Colors.grey[50]) // 메모 모드일 때 파란색 배경
              : Colors.grey[100], // 일시정지 시 회색 배경
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? (isMemoMode
                    ? Colors.blue[300]!
                    : Colors.grey[300]!) // 메모 모드일 때 파란색 테두리
                : Colors.grey[200]!, // 일시정지 시 연한 회색 테두리
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
              color: isEnabled
                  ? (isMemoMode
                      ? Colors.blue[700]
                      : Colors.grey[700]) // 메모 모드일 때 파란색 아이콘
                  : Colors.grey[400], // 일시정지 시 연한 회색 아이콘
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: isEnabled
                    ? (isMemoMode
                        ? Colors.blue[800]
                        : Colors.grey[800]) // 메모 모드일 때 파란색 텍스트
                    : Colors.grey[400], // 일시정지 시 연한 회색 텍스트
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

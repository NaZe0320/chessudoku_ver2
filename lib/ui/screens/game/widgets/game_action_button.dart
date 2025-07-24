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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        splashColor:
            isEnabled ? AppColors.primary.withValues(alpha: 0.2) : null,
        highlightColor:
            isEnabled ? AppColors.primary.withValues(alpha: 0.1) : null,
        child: Ink(
          decoration: BoxDecoration(
            color: isEnabled
                ? (isMemoMode
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.neutral50) // 메모 모드일 때 primary 배경
                : AppColors.neutral100, // 일시정지 시 neutral100 배경
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled
                  ? (isMemoMode
                      ? AppColors.primary
                      : AppColors.neutral300) // 메모 모드일 때 primary 테두리
                  : AppColors.neutral200, // 일시정지 시 neutral200 테두리
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled
                      ? (isMemoMode
                          ? AppColors.primary
                          : AppColors.neutral700) // 메모 모드일 때 primary 아이콘
                      : AppColors.neutral400, // 일시정지 시 neutral400 아이콘
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  text,
                  style: TextStyle(
                    color: isEnabled
                        ? (isMemoMode
                            ? AppColors.primary
                            : AppColors.neutral800) // 메모 모드일 때 primary 텍스트
                        : AppColors.neutral400, // 일시정지 시 neutral400 텍스트
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

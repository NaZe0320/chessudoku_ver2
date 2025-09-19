import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:flutter/material.dart';

/// 홈 화면 공통 컨테이너 버튼
class HomeMenuButton extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? leadingBackgroundColor;
  final Color? iconColor;
  final bool showChevron;
  final double height;
  final bool enabled;

  const HomeMenuButton({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leadingBackgroundColor,
    this.iconColor,
    this.showChevron = true,
    this.height = 84,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 플랫 스타일(설정 버튼 느낌)만 사용, 활성/비활성 테마 적용
    final Color effectiveCardColor = enabled
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.04);
    final List<BoxShadow> effectiveShadows = [];

    final Color effectiveLeadingBg = enabled
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.10);

    final Color effectiveIconColor = enabled
        ? AppColors.textWhite
        : AppColors.textWhite.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: effectiveCardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: enabled
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: effectiveShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: enabled ? onTap : null,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                _LeadingIcon(
                  icon: leadingIcon,
                  backgroundColor: effectiveLeadingBg,
                  iconColor: effectiveIconColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: enabled
                              ? AppColors.textWhite
                              : AppColors.textWhite.withValues(alpha: 0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: enabled
                                ? AppColors.textWhite.withValues(alpha: 0.85)
                                : AppColors.textWhite.withValues(alpha: 0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 28,
                    color: enabled
                        ? AppColors.textWhite.withValues(alpha: 0.9)
                        : AppColors.textWhite.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _LeadingIcon({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Icon(
        icon,
        size: 26,
        color: iconColor,
      ),
    );
  }
}




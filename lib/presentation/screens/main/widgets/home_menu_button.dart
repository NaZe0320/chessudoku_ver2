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
    // 글래스모피즘 스타일 - 활성/비활성 상태를 명확하게 구분
    final Color effectiveCardColor = enabled
        ? Colors.white.withValues(alpha: 0.15) // 활성화시 더 밝게
        : Colors.white.withValues(alpha: 0.03); // 비활성화시 더 어둡게

    final List<BoxShadow> effectiveShadows = enabled
        ? [
            // 활성화시 미묘한 글로우 효과
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            // 비활성화시 그림자 최소화
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ];

    final Color effectiveLeadingBg = enabled
        ? Colors.white.withValues(alpha: 0.25) // 활성화시 더 밝은 아이콘 배경
        : Colors.white.withValues(alpha: 0.08); // 비활성화시 더 어두운 아이콘 배경

    final Color effectiveIconColor = enabled
        ? AppColors.textWhite
        : AppColors.textWhite.withValues(alpha: 0.4); // 비활성화시 더 어둡게

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: effectiveCardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: enabled
              ? Colors.white.withValues(alpha: 0.25) // 활성화시 더 뚜렷한 경계선
              : Colors.white.withValues(alpha: 0.06), // 비활성화시 흐린 경계선
          width: enabled ? 1.2 : 0.8, // 활성화시 더 두꺼운 경계선
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
                              : AppColors.textWhite
                                  .withValues(alpha: 0.45), // 비활성화시 더 어둡게
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
                                : AppColors.textWhite
                                    .withValues(alpha: 0.35), // 비활성화시 더 어둡게
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
                        : AppColors.textWhite
                            .withValues(alpha: 0.3), // 비활성화시 더 어둡게
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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        // 미묘한 내부 그림자 효과로 깊이감 추가
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 26,
        color: iconColor,
      ),
    );
  }
}

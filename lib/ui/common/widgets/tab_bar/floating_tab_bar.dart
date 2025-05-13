import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/dimensions.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:flutter/material.dart';

class FloatingTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool isSticky;

  const FloatingTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isSticky,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.space4),
      margin: EdgeInsets.only(top: isSticky ? 0 : Spacing.space5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(Spacing.space1),
        child: Stack(
          children: [
            // 배경 인디케이터
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: selectedIndex *
                      (MediaQuery.of(context).size.width - Spacing.space8) /
                      tabs.length +
                  Spacing.space1,
              top: Spacing.space1,
              bottom: Spacing.space1,
              width: (MediaQuery.of(context).size.width -
                      Spacing.space8 -
                      (Spacing.space1 * 2)) /
                  tabs.length,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
              ),
            ),

            // 탭 항목들
            Row(
              children: List.generate(
                tabs.length,
                (index) => Expanded(
                  child: InkWell(
                    onTap: () => onTabSelected(index),
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: Spacing.space2),
                      child: Text(
                        tabs[index],
                        textAlign: TextAlign.center,
                        style: AppTypography.tabLabel.copyWith(
                          color: index == selectedIndex
                              ? Colors.white
                              : AppColors.textTertiary,
                          fontWeight: index == selectedIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

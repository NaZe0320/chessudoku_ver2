import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/dimensions.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<BottomNavItem> items;
  final VoidCallback? onCenterButtonPressed;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.onCenterButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Row(
              children: List.generate(
                items.length + (onCenterButtonPressed != null ? 1 : 0),
                (index) {
                  if (onCenterButtonPressed != null &&
                      index == items.length ~/ 2) {
                    return const Expanded(child: SizedBox());
                  }

                  final itemIndex = index < items.length ~/ 2
                      ? index
                      : onCenterButtonPressed != null
                          ? index - 1
                          : index;

                  return Expanded(
                    child: InkWell(
                      onTap: () => onItemSelected(itemIndex),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Icon(
                              items[itemIndex].icon,
                              color: selectedIndex == itemIndex
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: Spacing.space1),
                          Text(
                            items[itemIndex].label,
                            style: AppTypography.navLabel.copyWith(
                              color: selectedIndex == itemIndex
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              fontWeight: selectedIndex == itemIndex
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 중앙 떠있는 버튼
          if (onCenterButtonPressed != null)
            Positioned(
              top: -10,
              child: GestureDetector(
                onTap: onCenterButtonPressed,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(Spacing.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(78),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.label,
  });
}

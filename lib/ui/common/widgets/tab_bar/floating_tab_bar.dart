import 'package:chessudoku/domain/intents/tab_intent.dart';
import 'package:chessudoku/domain/notifiers/tab_notifier.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingTabBar extends ConsumerWidget {
  final List<String> tabs;
  final StateNotifierProvider<TabNotifier, TabState> provider;
  final EdgeInsetsGeometry margin;

  const FloatingTabBar({
    super.key,
    required this.tabs,
    required this.provider,
    this.margin = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(provider);
    final tabNotifier = ref.watch(provider.notifier);

    return Container(
      margin: margin,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: List.generate(tabs.length, (index) {
            final isSelected = tabState.selectedIndex == index;

            return Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => tabNotifier.handleIntent(ChangeTabIntent(index)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

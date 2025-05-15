import 'package:chessudoku/domain/intents/tab_intent.dart';
import 'package:chessudoku/domain/notifiers/tab_notifier.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloatingTabBar extends ConsumerWidget {
  final List<String> tabs;
  final StateNotifierProvider<TabNotifier, TabState> provider;

  const FloatingTabBar({
    super.key,
    required this.tabs,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(provider);
    final tabNotifier = ref.watch(provider.notifier);

    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = tabState.selectedIndex == index;

        return GestureDetector(
          onTap: () => tabNotifier.handleIntent(ChangeTabIntent(index)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

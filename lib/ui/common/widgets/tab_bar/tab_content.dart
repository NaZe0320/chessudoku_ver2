import 'package:chessudoku/domain/notifiers/tab_notifier.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabContent extends ConsumerWidget {
  final List<Widget> tabViews;
  final StateNotifierProvider<TabNotifier, TabState> provider;

  const TabContent({
    Key? key,
    required this.tabViews,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex =
        ref.watch(provider.select((state) => state.selectedIndex));
    return tabViews[selectedIndex];
  }
}

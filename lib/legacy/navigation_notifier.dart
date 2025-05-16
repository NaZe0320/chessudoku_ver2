import 'package:chessudoku/legacy/navigation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void selectTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }
}

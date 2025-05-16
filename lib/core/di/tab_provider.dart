import 'package:chessudoku/domain/notifiers/tab_notifier.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateNotifierProvider<TabNotifier, TabState> createTabProvider(String screenId) {
  return StateNotifierProvider<TabNotifier, TabState>((ref) => TabNotifier());
}

final homeTabProvider = createTabProvider('home');
final packTabProvider = createTabProvider('pack');
final profileTabProvider = createTabProvider('profile');
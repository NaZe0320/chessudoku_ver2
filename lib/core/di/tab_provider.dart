import 'package:chessudoku/domain/notifiers/tab_notifier.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateNotifierProvider<TabNotifier, TabState> createTabProvider(
    String screenId) {
  return StateNotifierProvider<TabNotifier, TabState>(
    (ref) => TabNotifier(screenId: screenId), // screenId 전달
    name: '${screenId}TabProvider', // 디버깅용 이름
  );
}

// Provider 정의
final homeTabProvider = createTabProvider('home');
final packTabProvider = createTabProvider('pack');
final friendTabProvider = createTabProvider('friend');
final profileTabProvider = createTabProvider('profile');
final friendsTabProvider = createTabProvider('friends');

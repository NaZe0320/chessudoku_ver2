import 'package:chessudoku/domain/intents/tab_intent.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabNotifier extends StateNotifier<TabState> {
  TabNotifier() : super(TabState());

  // 인텐트 처리 함수
  void handleIntent(TabIntent intent) {
    if (intent is ChangeTabIntent) {
      // 상태 업데이트 (선택된 탭 변경)
      state = state.copyWith(selectedIndex: intent.index);
    }
  }
}
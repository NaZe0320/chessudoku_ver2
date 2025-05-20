import 'package:chessudoku/domain/intents/tab_intent.dart';
import 'package:chessudoku/domain/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 개선된 tab_notifier.dart
class TabNotifier extends StateNotifier<TabState> {
  final String screenId;
  
  TabNotifier({required this.screenId}) : super(TabState());

  void handleIntent(TabIntent intent) {
    if (intent is ChangeTabIntent) {
      // 디버깅을 위한 로그
      debugPrint('[$screenId] Tab changed to index: ${intent.index}');
      state = state.copyWith(selectedIndex: intent.index);
    }
  }

  void handleState() {
    
  }
}
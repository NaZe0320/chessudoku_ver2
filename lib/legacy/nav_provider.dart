import 'package:chessudoku/legacy/select_tab_intent.dart';
import 'package:chessudoku/legacy/navigation_notifier.dart';
import 'package:chessudoku/legacy/navigation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//// 네비게이션 관련 프로바이더
final navigationNotifierProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);

// 네비게이션 상태 프로바이더 (읽기 전용)
final navigationProvider = Provider<NavigationState>(
  (ref) => ref.watch(navigationNotifierProvider),
);

// 네비게이션 인텐트 프로바이더
final navigationIntentProvider = Provider<SelectTabIntent>(
  (ref) => SelectTabIntent(ref),
);
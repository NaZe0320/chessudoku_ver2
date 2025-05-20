import 'package:chessudoku/core/base/base_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseNotifier<TIntent extends BaseIntent, TState>
    extends StateNotifier<TState> {
  BaseNotifier(TState initialState) : super(initialState);

  void handleIntent(TIntent intent) {
    try {
      onIntent(intent);
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }

    /// 자식 클래스에서 구현해야 하는 Intent 처리 로직
  void onIntent(TIntent intent);
  
  /// 에러 처리 (필요시 자식 클래스에서 오버라이드)
  void handleError(Object error, StackTrace stackTrace) {
    // 기본 에러 처리 로직
    print('Error in ${runtimeType}: $error');
    print('StackTrace: $stackTrace');
  }
}

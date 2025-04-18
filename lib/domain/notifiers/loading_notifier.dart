import 'package:chessudoku/core/utils/loading_manager.dart';
import 'package:chessudoku/domain/states/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingNotifier extends StateNotifier<LoadingState> {
  LoadingNotifier() : super(const LoadingState());

  void showLoading({String? message}) {
    // 이제 context 없이 직접 호출 가능
    LoadingManager.showLoading(message: message);
    
    // 상태 업데이트
    state = state.copyWith(isLoading: true, message: message);
  }

  void hideLoading() {
    // 이제 context 없이 직접 호출 가능
    LoadingManager.hideLoading();
    
    // 상태 업데이트
    state = state.copyWith(isLoading: false);
  }
}
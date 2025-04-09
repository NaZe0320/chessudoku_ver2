import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/data/models/user.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading());

  // 로딩 상태로 변경
  void setLoading() {
    state = const AsyncValue.loading();
  }

  // 사용자 정보 업데이트
  void setUser(User? user) {
    state = AsyncValue.data(user);
  }

  // 에러 상태로 변경
  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  // 로그아웃 상태로 변경
  void setSignedOut() {
    state = const AsyncValue.data(null);
  }
}

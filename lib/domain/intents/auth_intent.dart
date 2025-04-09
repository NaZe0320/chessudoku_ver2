import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/data/repositories/firebase_auth_repository.dart';
import 'package:chessudoku/domain/notifiers/auth_notifier.dart';
import 'package:chessudoku/core/di/auth_providers.dart';

class AuthIntent {
  final Ref ref;

  AuthIntent(this.ref) {
    _init();
  }

  // 노티파이어에 대한 참조를 쉽게 얻기 위한 getter
  AuthNotifier get _notifier => ref.read(authProvider.notifier);

  // 레포지토리에 대한 참조를 쉽게 얻기 위한 getter
  FirebaseAuthRepository get _repository =>
      ref.read(firebaseAuthRepositoryProvider);

  Future<void> _init() async {
    _notifier.setLoading();
    try {
      final user = await _repository.getCurrentUser();
      if (user == null) {
        // 현재 사용자가 없다면 캐시된 인증 정보로 로그인 시도
        final cachedUser = await _repository.signInWithCachedCredentials();
        _notifier.setUser(cachedUser);
      } else {
        _notifier.setUser(user);
      }
    } catch (e, stack) {
      _notifier.setError(e, stack);
    }
  }

  Future<void> signIn(String email, String password) async {
    _notifier.setLoading();
    try {
      final user =
          await _repository.signInWithEmailAndPassword(email, password);
      _notifier.setUser(user);
    } catch (e, stack) {
      _notifier.setError(e, stack);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    _notifier.setLoading();
    try {
      final user =
          await _repository.createUserWithEmailAndPassword(email, password);
      _notifier.setUser(user);
    } catch (e, stack) {
      _notifier.setError(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      _notifier.setUser(null);
    } catch (e, stack) {
      _notifier.setError(e, stack);
      rethrow;
    }
  }
}

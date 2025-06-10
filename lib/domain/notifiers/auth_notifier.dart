import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/base/base_notifier.dart';
import '../intents/auth_intent.dart';
import '../states/auth_state.dart';
import '../../data/services/device_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/user.dart';

class AuthNotifier extends BaseNotifier<AuthIntent, AuthState> {
  final DeviceService _deviceService = DeviceService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthNotifier() : super(const AuthState.initial()) {
    // Firebase Auth 상태 변화 감지
    firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebaseUser) {
      if (firebaseUser != null) {
        // 이미 복구된 계정이 있는지 확인
        if (state.user != null) {
          debugPrint('AuthNotifier: 이미 복구된 계정 있음, Firebase Auth 무시');
          return;
        }

        // Firestore에 사용자 정보 저장/업데이트 처리
        _handleFirebaseUserChange(firebaseUser);
      } else {
        // 계정 복구 중이 아닌 경우만 로그아웃 상태로 변경
        if (state.user == null) {
          state = const AuthState.unauthenticated();
        }
      }
    });
  }

  @override
  void onIntent(AuthIntent intent) {
    switch (intent) {
      case SignInWithGoogleIntent():
        _signInWithGoogle();
        break;
      case SignInWithAppleIntent():
        _signInWithApple();
        break;
      case SignInAnonymouslyIntent():
        _signInAnonymously();
        break;
      case SignOutIntent():
        _signOut();
        break;
      case CheckAuthStatusIntent():
        // 현재 인증 상태를 확인하는 로직 (필요시 구현)
        break;
    }
  }

  /// Firebase 사용자 변경 처리
  Future<void> _handleFirebaseUserChange(
      firebase_auth.User firebaseUser) async {
    try {
      final deviceId = await _deviceService.getDeviceId();

      // 디바이스 ID로 기존 계정 확인
      User? existingUser = await _firestoreService.findUserByDeviceId(deviceId);

      if (existingUser != null) {
        // 기존 계정이 있는 경우 - 해당 계정 정보 사용
        final updatedUser = existingUser.copyWith(
          lastLoginAt: DateTime.now(),
        );

        // Firestore에 로그인 시간 업데이트
        await _firestoreService.updateUserLastLogin(existingUser.id);
        await _firestoreService.updateDeviceMappingLastUsed(deviceId);

        state = AuthState.authenticated(updatedUser);
        debugPrint('AuthNotifier: 기존 계정으로 로그인 - ${existingUser.email}');
      } else {
        // 새로운 계정인 경우 - 새 계정 생성
        final newUser = User(
          id: firebaseUser.uid,
          email:
              firebaseUser.email ?? '익명사용자@${deviceId.substring(0, 8)}.local',
          displayName: firebaseUser.displayName ?? '익명 사용자',
          isOfflineAuthenticated: firebaseUser.isAnonymous,
          deviceId: deviceId,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Firestore에 새 계정 저장
        await _firestoreService.createUserWithDeviceMapping(
          user: newUser,
          deviceId: deviceId,
        );

        state = AuthState.authenticated(newUser);
        debugPrint('AuthNotifier: 새 계정 생성 - ${newUser.email}');
      }
    } catch (e) {
      debugPrint('AuthNotifier: Firebase 사용자 처리 중 오류: $e');
      // 오류 발생 시 기본 사용자 정보로 처리
      final fallbackUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '사용자',
        displayName: firebaseUser.displayName ?? '사용자',
        isOfflineAuthenticated: firebaseUser.isAnonymous,
      );
      state = AuthState.authenticated(fallbackUser);
    }
  }

  // Google 로그인
  Future<void> _signInWithGoogle() async {
    try {
      state = const AuthState.loading();

      // Google Sign In 트리거
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        state = const AuthState.unauthenticated(errorMessage: '로그인이 취소되었습니다.');
        return;
      }

      // Google Auth 자격 증명 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 자격 증명 생성
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Auth에 로그인
      await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
    } catch (e) {
      state = AuthState.unauthenticated(
          errorMessage: 'Google 로그인 실패: ${e.toString()}');
      debugPrint('Google 로그인 실패: ${e.toString()}');
    }
  }

  // Apple 로그인
  Future<void> _signInWithApple() async {
    try {
      state = const AuthState.loading();

      // Apple Sign In 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // OAuthProvider 생성
      final oauthCredential =
          firebase_auth.OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Firebase Auth에 로그인
      await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(oauthCredential);
    } catch (e) {
      state = AuthState.unauthenticated(
          errorMessage: 'Apple 로그인 실패: ${e.toString()}');
      debugPrint('Apple 로그인 실패: ${e.toString()}');
    }
  }

  // 익명 로그인 (디바이스 ID 기반 계정 복구 포함)
  Future<void> _signInAnonymously() async {
    try {
      state = const AuthState.loading();

      // 1. 먼저 계정 복구 시도 (임시 익명 로그인으로 권한 확보)
      final recoveredUser = await _attemptDeviceBasedAccountRecovery();

      if (recoveredUser != null) {
        state = AuthState.authenticated(recoveredUser);
        debugPrint('AuthNotifier: 계정 복구 완료 - ${recoveredUser.email}');
        return;
      }

      // 2. 기존 계정이 없으면 새로운 익명 로그인
      debugPrint('AuthNotifier: 기존 계정 없음, 새로운 익명 계정 생성');
      await firebase_auth.FirebaseAuth.instance.signInAnonymously();
      // _handleFirebaseUserChange에서 새 계정 생성
    } catch (e) {
      state =
          AuthState.unauthenticated(errorMessage: '익명 로그인 실패: ${e.toString()}');
      debugPrint('익명 로그인 실패: ${e.toString()}');
    }
  }

  // 디바이스 기반 계정 복구 시도 (인증 없이)
  Future<User?> _attemptDeviceBasedAccountRecovery() async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      debugPrint('AuthNotifier: 계정 복구 시도 - ${deviceId.substring(0, 8)}...');

      // 인증 없이 바로 기존 계정 확인
      final existingUser = await _firestoreService.findUserByDeviceId(deviceId);

      if (existingUser != null) {
        // 기존 계정 발견
        debugPrint('AuthNotifier: 기존 계정 발견 - ${existingUser.email}');

        // 기존 계정 로그인 시간 업데이트 (나중에 인증 후 업데이트)
        final updatedUser = existingUser.copyWith(
          lastLoginAt: DateTime.now(),
        );

        return updatedUser;
      } else {
        // 기존 계정 없음
        debugPrint('AuthNotifier: 기존 계정 없음');
        return null;
      }
    } catch (e) {
      debugPrint('AuthNotifier: 계정 복구 실패: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> _signOut() async {
    try {
      // 디바이스 매핑은 유지 (다음 로그인 시 계정 복구를 위해)
      await firebase_auth.FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state =
          AuthState.unauthenticated(errorMessage: '로그아웃 실패: ${e.toString()}');
      debugPrint('로그아웃 실패: ${e.toString()}');
    }
  }

  // 현재 사용자가 익명 사용자인지 확인
  bool get isAnonymousUser {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    return currentUser?.isAnonymous ?? false;
  }

  // 계정 완전 삭제 (사용자 데이터 + 디바이스 매핑 모두 삭제)
  Future<void> deleteAccount() async {
    try {
      if (state.user == null) return;

      final userId = state.user!.id;

      // Firestore에서 사용자 데이터 및 관련된 모든 디바이스 매핑 삭제
      await _firestoreService.deleteUserAccount(userId);

      // Firebase Auth 계정 삭제
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      await currentUser?.delete();

      // 로컬 디바이스 ID도 초기화
      await _deviceService.resetDeviceId();

      state = const AuthState.unauthenticated();
      debugPrint('AuthNotifier: 계정 완전 삭제 완료 (사용자 데이터 + 디바이스 매핑)');
    } catch (e) {
      debugPrint('AuthNotifier: 계정 삭제 중 오류: $e');
      state =
          AuthState.unauthenticated(errorMessage: '계정 삭제 실패: ${e.toString()}');
    }
  }
}

// Provider 생성
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

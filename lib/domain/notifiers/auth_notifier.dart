import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../states/auth_state.dart';
import '../../data/models/user.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    // Firebase Auth 상태 변화 감지
    firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebaseUser) {
      if (firebaseUser != null) {
        final user = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
        );
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  // Google 로그인
  Future<void> signInWithGoogle() async {
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
  Future<void> signInWithApple() async {
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

  // 익명 로그인
  Future<void> signInAnonymously() async {
    try {
      state = const AuthState.loading();
      await firebase_auth.FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      state =
          AuthState.unauthenticated(errorMessage: '익명 로그인 실패: ${e.toString()}');

      debugPrint('익명 로그인 실패: ${e.toString()}');
    }
  }

  // 익명 계정을 Google 계정으로 연결
  Future<void> linkAnonymousWithGoogle() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        state = const AuthState.unauthenticated(errorMessage: '익명 사용자가 아닙니다.');
        return;
      }

      state = const AuthState.loading();

      // Google Sign In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AuthState.unauthenticated(errorMessage: '로그인이 취소되었습니다.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 익명 계정과 Google 계정 연결
      await currentUser.linkWithCredential(credential);
    } catch (e) {
      state = AuthState.unauthenticated(
          errorMessage: 'Google 계정 연결 실패: ${e.toString()}');
      debugPrint('Google 계정 연결 실패: ${e.toString()}');
    }
  }

  // 익명 계정을 Apple 계정으로 연결
  Future<void> linkAnonymousWithApple() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        state = const AuthState.unauthenticated(errorMessage: '익명 사용자가 아닙니다.');
        return;
      }

      state = const AuthState.loading();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential =
          firebase_auth.OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // 익명 계정과 Apple 계정 연결
      await currentUser.linkWithCredential(oauthCredential);
    } catch (e) {
      state = AuthState.unauthenticated(
          errorMessage: 'Apple 계정 연결 실패: ${e.toString()}');
      debugPrint('Apple 계정 연결 실패: ${e.toString()}');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
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
}

// Provider 생성
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

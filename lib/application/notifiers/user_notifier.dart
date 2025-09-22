import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/application/intents/user_intent.dart';
import 'package:chessudoku/domain/entities/user.dart';
import 'package:chessudoku/data/services/user_service.dart';
import 'package:flutter/services.dart';

import 'dart:developer' as developer;

/// 사용자 관리 Notifier (상태 없이 단순 비즈니스 로직만 처리)
class UserNotifier extends StateNotifier<User?> {
  final UserService _userService;

  UserNotifier(this._userService) : super(null);

  /// Intent 처리
  Future<void> handleIntent(UserIntent intent) async {
    switch (intent) {
      case InitializeUserIntent():
        await _handleInitializeUser();
      case WithdrawUserIntent():
        await _handleWithdrawUser();
    }
  }

  /// 사용자 초기화 처리 - 테스트용 로그 추가
  Future<User?> _handleInitializeUser() async {
    developer.log('🚀 [TEST] UserNotifier 사용자 초기화 시작', name: 'UserNotifier');

    try {
      developer.log('🔄 [TEST] UserService.initializeUser() 호출 중...',
          name: 'UserNotifier');
      final user = await _userService.initializeUser();

      developer.log(
          '📝 [TEST] UserService 결과 수신: ${user != null ? user.userId : "null"}',
          name: 'UserNotifier');
      state = user;

      if (user != null) {
        developer.log('✅ [TEST] UserNotifier 사용자 초기화 성공: ${user.userId}',
            name: 'UserNotifier');
        developer.log(
            '👤 [TEST] 사용자 정보 - 닉네임: ${user.nickname}, 디바이스ID: ${user.deviceId}',
            name: 'UserNotifier');
      } else {
        developer.log('❌ [TEST] UserNotifier 사용자 초기화 실패 - null 반환됨',
            name: 'UserNotifier');
        developer.log('🚨 [TEST] 이 상황은 발생하면 안 됨!', name: 'UserNotifier');
      }

      return user;
    } catch (e) {
      developer.log('💥 [TEST] UserNotifier 사용자 초기화 예외 발생: $e',
          name: 'UserNotifier');
      developer.log('🔧 [TEST] 상태를 null로 설정', name: 'UserNotifier');
      state = null;
      return null;
    }
  }

  /// 사용자 탈퇴 처리 (앱 종료)
  Future<void> _handleWithdrawUser() async {
    developer.log('사용자 탈퇴 시작', name: 'UserNotifier');

    try {
      await _userService.withdrawUser();
      state = null;

      developer.log('사용자 탈퇴 완료 - 앱 종료', name: 'UserNotifier');

      // 앱 종료
      SystemNavigator.pop();
    } catch (e) {
      developer.log('사용자 탈퇴 오류: $e', name: 'UserNotifier');
      // 오류가 발생해도 앱 종료
      SystemNavigator.pop();
    }
  }
}

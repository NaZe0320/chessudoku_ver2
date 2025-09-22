import 'dart:convert';
import 'dart:developer' as developer;
import 'package:chessudoku/domain/entities/user.dart';
import 'package:chessudoku/domain/repositories/user_repository.dart';
import 'package:chessudoku/core/utils/device_utils.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 사용자 관련 비즈니스 로직을 처리하는 서비스
class UserService {
  final UserRepository _userRepository;
  final CacheService _cacheService;

  static const String _cachedUserKey = 'current_user';

  UserService(this._userRepository, this._cacheService);

  /// 사용자 초기화 (스플래시에서 호출) - 테스트용 로그 추가
  /// 서버 통신 실패해도 기본 사용자로 계속 진행
  Future<User?> initializeUser() async {
    try {
      developer.log('🔄 [TEST] 사용자 초기화 시작', name: 'UserService');

      // 1. 캐시된 사용자 확인
      developer.log('📋 [TEST] 캐시된 사용자 확인 중...', name: 'UserService');
      final cachedUser = await getCachedUser();
      if (cachedUser != null) {
        developer.log('✅ [TEST] 캐시된 사용자 발견: ${cachedUser.userId}',
            name: 'UserService');
        return cachedUser;
      } else {
        developer.log('❌ [TEST] 캐시된 사용자 없음', name: 'UserService');
      }

      // 2. 네트워크 연결 확인 후 서버 통신 시도 (실패해도 계속 진행)
      developer.log('🌐 [TEST] 네트워크 연결 상태 확인 중...', name: 'UserService');
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      developer.log('🌐 [TEST] 네트워크 상태: ${isOnline ? "온라인" : "오프라인"}',
          name: 'UserService');

      if (isOnline) {
        try {
          // 3. 온라인이면 서버에서 조회/생성 시도
          developer.log('🔗 [TEST] 서버 통신 시도 중...', name: 'UserService');
          final deviceId = await getCurrentDeviceId();
          developer.log('📱 [TEST] 디바이스 ID: $deviceId', name: 'UserService');

          final user = await _userRepository.getUserByDeviceId(deviceId);

          if (user != null) {
            developer.log('✅ [TEST] 서버에서 사용자 조회/등록 성공: ${user.userId}',
                name: 'UserService');
            await cacheUser(user);
            developer.log('💾 [TEST] 사용자 캐시 저장 완료', name: 'UserService');
            return user;
          } else {
            developer.log('❌ [TEST] 서버에서 사용자 조회/등록 실패 (null 반환)',
                name: 'UserService');
          }
        } catch (e) {
          developer.log('💥 [TEST] 서버 통신 예외 발생: $e', name: 'UserService');
          developer.log('🔄 [TEST] 서버 통신 실패하지만 계속 진행', name: 'UserService');
        }
      } else {
        developer.log('📴 [TEST] 오프라인 상태이지만 계속 진행', name: 'UserService');
      }

      // 4. 서버 실패하거나 오프라인인 경우 null 반환
      developer.log('❌ [TEST] 서버 통신 실패/오프라인 - null 반환', name: 'UserService');
      return null;
    } catch (e) {
      developer.log('💥 [TEST] 사용자 초기화 메인 예외 발생: $e', name: 'UserService');
      developer.log('🔧 [TEST] 예외 처리 시작 - 기존 캐시 확인', name: 'UserService');

      // 오류 시에도 기존 캐시된 사용자 재사용 시도
      try {
        final existingUser = await getCachedUser();
        if (existingUser != null) {
          developer.log('♻️ [TEST] 기존 캐시된 사용자 재사용: ${existingUser.userId}',
              name: 'UserService');
          return existingUser;
        } else {
          developer.log('❌ [TEST] 기존 캐시된 사용자도 없음', name: 'UserService');
        }
      } catch (e2) {
        developer.log('💥 [TEST] 캐시된 사용자 조회도 실패: $e2', name: 'UserService');
      }

      // 모든 방법 실패 시 null 반환
      developer.log('💀 [TEST] 모든 사용자 초기화 방법 실패 - null 반환',
          name: 'UserService');
      return null;
    }
  }

  /// 사용자 탈퇴 (앱 종료)
  Future<void> withdrawUser() async {
    try {
      developer.log('사용자 탈퇴 시작', name: 'UserService');

      final user = await getCachedUser();
      if (user != null) {
        // 온라인이면 서버에 탈퇴 요청
        final connectivity = Connectivity();
        final isOnline =
            await connectivity.checkConnectivity() != ConnectivityResult.none;

        if (isOnline) {
          await _userRepository.withdrawUser(user.userId);
          developer.log('서버 탈퇴 요청 완료', name: 'UserService');
        }
      }

      // 로컬 캐시 삭제
      await clearCachedUser();
      developer.log('사용자 탈퇴 완료', name: 'UserService');
    } catch (e) {
      developer.log('사용자 탈퇴 실패: $e', name: 'UserService');
      // 실패해도 캐시는 삭제
      await clearCachedUser();
    }
  }

  /// 현재 디바이스 ID 가져오기
  Future<String> getCurrentDeviceId() async {
    return await DeviceUtils.getDeviceId();
  }

  /// 사용자 정보를 캐시에 저장
  Future<void> cacheUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _cacheService.setString(_cachedUserKey, userJson);
      developer.log('사용자 캐시 저장 완료: ${user.userId}', name: 'UserService');
    } catch (e) {
      developer.log('사용자 캐시 저장 실패: $e', name: 'UserService');
    }
  }

  /// 캐시에서 사용자 정보 가져오기
  Future<User?> getCachedUser() async {
    try {
      final userJsonString = _cacheService.getString(_cachedUserKey);
      if (userJsonString != null && userJsonString.isNotEmpty) {
        final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
        final user = User.fromJson(userJson);
        developer.log('캐시된 사용자 로드: ${user.userId}', name: 'UserService');
        return user;
      }
      return null;
    } catch (e) {
      developer.log('캐시된 사용자 로드 실패: $e', name: 'UserService');
      return null;
    }
  }

  /// 캐시된 사용자 정보 삭제
  Future<void> clearCachedUser() async {
    try {
      await _cacheService.remove(_cachedUserKey);
      developer.log('사용자 캐시 삭제 완료', name: 'UserService');
    } catch (e) {
      developer.log('사용자 캐시 삭제 실패: $e', name: 'UserService');
    }
  }
}

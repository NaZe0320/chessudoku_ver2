import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_service.dart';
import '../sync/sync_manager.dart';

import '../../domain/repositories/game_save_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../data/services/device_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/user_profile.dart';

/// 앱 초기화를 관리하는 매니저
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  final NetworkService _networkService = NetworkService();
  final SyncManager _syncManager = SyncManager();
  final DeviceService _deviceService = DeviceService();
  final FirestoreService _firestoreService = FirestoreService();

  static const String _firstLaunchKey = 'is_first_launch';

  /// 앱 초기화
  Future<InitializationResult> initialize({
    required GameSaveRepository gameSaveRepository,
    required UserProfileRepository userProfileRepository,
  }) async {
    try {
      developer.log('앱 초기화 시작', name: 'AppInitializer');

      // 네트워크 서비스 초기화
      await _networkService.initialize();

      // 동기화 매니저는 main.dart에서 이미 초기화됨
      developer.log(
          '동기화 매니저 상태 확인 - 온라인: ${_syncManager.isOnline}, 큐 크기: ${_syncManager.queueSize}',
          name: 'AppInitializer');

      // 최초 실행 여부 확인
      final isFirstLaunch = await _checkFirstLaunch();

      if (isFirstLaunch) {
        // 최초 실행 시 온라인 체크
        final isOnline = _networkService.isOnline;

        if (!isOnline) {
          developer.log('최초 실행 시 오프라인 상태 감지', name: 'AppInitializer');
          return InitializationResult.firstLaunchOffline;
        }

        // 최초 실행 시 온라인 상태 - 기본 데이터 다운로드 및 사용자 프로필 생성
        await _downloadInitialData();
        await _initializeUserProfile(userProfileRepository);
        await _markFirstLaunchComplete();

        developer.log('최초 실행 초기화 완료', name: 'AppInitializer');
        return InitializationResult.success;
      } else {
        // 일반 실행 - 저장된 게임 및 사용자 프로필 확인
        await _checkSavedGame(gameSaveRepository);
        await _ensureUserProfile(userProfileRepository);

        developer.log('일반 실행 초기화 완료', name: 'AppInitializer');
        return InitializationResult.success;
      }
    } catch (e) {
      developer.log('앱 초기화 실패: $e', name: 'AppInitializer');
      return InitializationResult.failure;
    }
  }

  /// 앱 재실행을 위한 초기화 (네트워크 복구 후)
  Future<InitializationResult> reinitialize({
    required GameSaveRepository gameSaveRepository,
    required UserProfileRepository userProfileRepository,
  }) async {
    try {
      developer.log('앱 재초기화 시작', name: 'AppInitializer');

      // 네트워크 상태 재확인
      final isOnline = _networkService.isOnline;
      if (!isOnline) {
        developer.log('재초기화 시에도 오프라인 상태', name: 'AppInitializer');
        return InitializationResult.firstLaunchOffline;
      }

      // 최초 실행 여부 재확인
      final isFirstLaunch = await _checkFirstLaunch();

      if (isFirstLaunch) {
        // 최초 실행 데이터 다운로드 및 사용자 프로필 생성
        await _downloadInitialData();
        await _initializeUserProfile(userProfileRepository);
        await _markFirstLaunchComplete();

        developer.log('재초기화 - 최초 실행 완료', name: 'AppInitializer');
        return InitializationResult.success;
      } else {
        // 일반 실행 - 기본 확인만
        await _ensureUserProfile(userProfileRepository);

        developer.log('재초기화 - 일반 실행 완료', name: 'AppInitializer');
        return InitializationResult.success;
      }
    } catch (e) {
      developer.log('앱 재초기화 실패: $e', name: 'AppInitializer');
      return InitializationResult.failure;
    }
  }

  /// 최초 실행 여부 확인
  Future<bool> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      developer.log('최초 실행 확인 실패: $e', name: 'AppInitializer');
      return true;
    }
  }

  /// 최초 실행 완료 표시
  Future<void> _markFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, false);
    } catch (e) {
      developer.log('최초 실행 완료 표시 실패: $e', name: 'AppInitializer');
    }
  }

  /// 초기 데이터 다운로드
  Future<void> _downloadInitialData() async {
    try {
      developer.log('초기 데이터 다운로드 시작', name: 'AppInitializer');

      // 기본 퍼즐 데이터 다운로드
      await _downloadPuzzleData();

      // 언어팩 데이터 다운로드
      await _downloadLanguagePackData();

      // 기타 필수 데이터 다운로드
      await _downloadOtherEssentialData();

      developer.log('초기 데이터 다운로드 완료', name: 'AppInitializer');
    } catch (e) {
      developer.log('초기 데이터 다운로드 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 퍼즐 데이터 다운로드
  Future<void> _downloadPuzzleData() async {
    try {
      developer.log('퍼즐 데이터 다운로드 시작', name: 'AppInitializer');

      // TODO: 실제 API 호출로 퍼즐 데이터 다운로드
      // - 난이도별 기본 퍼즐 세트
      // - 데일리 챌린지 퍼즐
      // - 체스 기물 배치 데이터

      await Future.delayed(const Duration(milliseconds: 500));
      developer.log('퍼즐 데이터 다운로드 완료', name: 'AppInitializer');
    } catch (e) {
      developer.log('퍼즐 데이터 다운로드 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 언어팩 데이터 다운로드
  Future<void> _downloadLanguagePackData() async {
    try {
      developer.log('언어팩 데이터 다운로드 시작', name: 'AppInitializer');

      // TODO: 실제 API 호출로 언어팩 데이터 다운로드
      // - 한국어 언어팩
      // - 영어 언어팩
      // - 기타 지원 언어팩

      await Future.delayed(const Duration(milliseconds: 300));
      developer.log('언어팩 데이터 다운로드 완료', name: 'AppInitializer');
    } catch (e) {
      developer.log('언어팩 데이터 다운로드 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 기타 필수 데이터 다운로드
  Future<void> _downloadOtherEssentialData() async {
    try {
      developer.log('기타 필수 데이터 다운로드 시작', name: 'AppInitializer');

      // TODO: 실제 API 호출로 기타 데이터 다운로드
      // - 앱 설정 데이터
      // - 통계 초기값
      // - 업데이트 정보

      await Future.delayed(const Duration(milliseconds: 200));
      developer.log('기타 필수 데이터 다운로드 완료', name: 'AppInitializer');
    } catch (e) {
      developer.log('기타 필수 데이터 다운로드 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 사용자 프로필 초기화 (최초 실행 시)
  Future<void> _initializeUserProfile(
      UserProfileRepository userProfileRepository) async {
    try {
      developer.log('사용자 프로필 초기화 시작', name: 'AppInitializer');

      final deviceId = await _deviceService.getDeviceId();
      developer.log('생성할 DeviceId: $deviceId', name: 'AppInitializer');

      final userProfile = await userProfileRepository.createUserProfile(
        UserProfile(
          deviceId: deviceId,
          username: '플레이어',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ),
      );

      developer.log('사용자 프로필 초기화 완료: ${userProfile.deviceId}',
          name: 'AppInitializer');
    } catch (e) {
      developer.log('사용자 프로필 초기화 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 사용자 프로필 확인 및 복구 (일반 실행 시)
  Future<void> _ensureUserProfile(
      UserProfileRepository userProfileRepository) async {
    try {
      developer.log('사용자 프로필 확인 시작', name: 'AppInitializer');

      var userProfile = await userProfileRepository.getUserProfile();

      if (userProfile == null) {
        developer.log('사용자 프로필이 없어 새로 생성', name: 'AppInitializer');
        await _initializeUserProfile(userProfileRepository);
      } else {
        developer.log('기존 사용자 프로필 확인됨: ${userProfile.deviceId}',
            name: 'AppInitializer');
        // 마지막 로그인 시간 업데이트
        await userProfileRepository.updateLastLogin();
      }
    } catch (e) {
      developer.log('사용자 프로필 확인 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 저장된 게임 확인
  Future<void> _checkSavedGame(GameSaveRepository gameSaveRepository) async {
    try {
      developer.log('저장된 게임 확인 시작', name: 'AppInitializer');

      final hasSavedGame = await gameSaveRepository.hasSavedGame();
      developer.log('저장된 게임 존재 여부: $hasSavedGame', name: 'AppInitializer');

      if (hasSavedGame) {
        final savedGameInfo = await gameSaveRepository.getSavedGameInfo();
        developer.log('저장된 게임 정보: $savedGameInfo', name: 'AppInitializer');
      }
    } catch (e) {
      developer.log('저장된 게임 확인 실패: $e', name: 'AppInitializer');
      // 저장된 게임 확인 실패는 치명적이지 않으므로 rethrow하지 않음
    }
  }

  /// 현재 온라인 상태 확인
  bool get isOnline => _networkService.isOnline;

  /// 동기화 매니저 접근
  SyncManager get syncManager => _syncManager;

  /// 네트워크 서비스 접근
  NetworkService get networkService => _networkService;
}

/// 초기화 결과 타입
enum InitializationResult {
  /// 성공
  success,

  /// 최초 실행 시 오프라인
  firstLaunchOffline,

  /// 실패
  failure,
}

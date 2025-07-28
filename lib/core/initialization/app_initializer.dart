import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_service.dart';
import '../sync/sync_manager.dart';
import '../offline/offline_manager.dart';

/// 앱 초기화를 관리하는 매니저
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  final NetworkService _networkService = NetworkService();
  final SyncManager _syncManager = SyncManager();
  final OfflineManager _offlineManager = OfflineManager();

  static const String _firstLaunchKey = 'is_first_launch';

  /// 앱 초기화
  Future<InitializationResult> initialize() async {
    try {
      developer.log('앱 초기화 시작', name: 'AppInitializer');

      // 네트워크 서비스 초기화
      await _networkService.initialize();

      // 동기화 매니저 초기화
      await _syncManager.initialize();

      // 최초 실행 여부 확인
      final isFirstLaunch = await _checkFirstLaunch();

      if (isFirstLaunch) {
        // 최초 실행 시 온라인 체크
        final isOnline = _networkService.isOnline;

        if (!isOnline) {
          developer.log('최초 실행 시 오프라인 상태 감지', name: 'AppInitializer');
          return InitializationResult.firstLaunchOffline;
        }

        // 최초 실행 시 온라인 상태 - 기본 데이터 다운로드
        await _downloadInitialData();
        await _markFirstLaunchComplete();

        developer.log('최초 실행 초기화 완료', name: 'AppInitializer');
        return InitializationResult.success;
      } else {
        // 일반 실행
        developer.log('일반 실행 초기화 완료', name: 'AppInitializer');
        return InitializationResult.success;
      }
    } catch (e) {
      developer.log('앱 초기화 실패: $e', name: 'AppInitializer');
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

      // TODO: 실제 초기 데이터 다운로드 로직 구현
      // - 기본 퍼즐 데이터
      // - 언어팩 데이터
      // - 기타 필수 데이터

      await Future.delayed(const Duration(seconds: 2)); // 임시 지연

      developer.log('초기 데이터 다운로드 완료', name: 'AppInitializer');
    } catch (e) {
      developer.log('초기 데이터 다운로드 실패: $e', name: 'AppInitializer');
      rethrow;
    }
  }

  /// 현재 온라인 상태 확인
  bool get isOnline => _networkService.isOnline;

  /// 동기화 매니저 접근
  SyncManager get syncManager => _syncManager;

  /// 오프라인 매니저 접근
  OfflineManager get offlineManager => _offlineManager;
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

import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/game_save_repository.dart';

/// 앱 초기화를 관리하는 매니저
/// TODO: 새로운 User 시스템으로 재구현 필요
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  /// 앱 초기화 (간소화된 버전)
  Future<InitializationResult> initialize({
    required GameSaveRepository gameSaveRepository,
  }) async {
    try {
      developer.log('앱 초기화 시작', name: 'AppInitializer');

      // 네트워크 상태 확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      // 저장된 게임 확인
      await _checkSavedGame(gameSaveRepository);

      developer.log('앱 초기화 완료 (온라인: $isOnline)', name: 'AppInitializer');
      return InitializationResult.success;
    } catch (e) {
      developer.log('앱 초기화 실패: $e', name: 'AppInitializer');
      return InitializationResult.failure;
    }
  }

  /// 앱 재실행을 위한 초기화 (네트워크 복구 후)
  Future<InitializationResult> reinitialize({
    required GameSaveRepository gameSaveRepository,
  }) async {
    try {
      developer.log('앱 재초기화 시작', name: 'AppInitializer');

      // 네트워크 상태 재확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('재초기화 시에도 오프라인 상태', name: 'AppInitializer');
        return InitializationResult.dataRequiredOffline;
      }

      developer.log('재초기화 완료', name: 'AppInitializer');
      return InitializationResult.success;
    } catch (e) {
      developer.log('앱 재초기화 실패: $e', name: 'AppInitializer');
      return InitializationResult.failure;
    }
  }

  /// 저장된 게임 확인
  Future<void> _checkSavedGame(GameSaveRepository gameSaveRepository) async {
    try {
      developer.log('저장된 게임 확인 시작', name: 'AppInitializer');

      final hasSavedGame = await gameSaveRepository.hasSavedGame();
      developer.log('저장된 게임 존재 여부: $hasSavedGame', name: 'AppInitializer');

      if (hasSavedGame) {
        final savedGameData = gameSaveRepository.loadCurrentGame();
        developer.log('저장된 게임 데이터: ${savedGameData?.difficulty}',
            name: 'AppInitializer');
      }
    } catch (e) {
      developer.log('저장된 게임 확인 실패: $e', name: 'AppInitializer');
      // 저장된 게임 확인 실패는 치명적이지 않으므로 rethrow하지 않음
    }
  }
}

/// 초기화 결과 타입
enum InitializationResult {
  /// 성공
  success,

  /// 데이터 부족으로 인한 오프라인 모드 필요
  dataRequiredOffline,

  /// 실패
  failure,
}

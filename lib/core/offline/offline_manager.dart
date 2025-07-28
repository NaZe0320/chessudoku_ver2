import 'dart:developer' as developer;
import '../network/network_service.dart';
import '../sync/sync_manager.dart';

/// 오프라인 상태를 관리하는 매니저
class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  final NetworkService _networkService = NetworkService();
  final SyncManager _syncManager = SyncManager();

  /// 오프라인 상태에서 새 퍼즐 시작 시도 시 처리
  Future<bool> canStartNewPuzzle() async {
    final isOnline = _networkService.isOnline;

    if (!isOnline) {
      developer.log('오프라인 상태에서 새 퍼즐 시작 시도', name: 'OfflineManager');
      return false;
    }

    return true;
  }

  /// 오프라인 상태에서 프로필 업데이트 시도 시 처리
  Future<bool> canUpdateProfile() async {
    // 오프라인에서도 로컬 업데이트는 가능하지만, 서버 동기화는 지연됨
    return true;
  }

  /// 오프라인 상태에서 퍼즐 완료 시도 시 처리
  Future<bool> canCompletePuzzle() async {
    // 오프라인에서도 로컬 완료는 가능하지만, 서버 동기화는 지연됨
    return true;
  }

  /// 오프라인 상태 메시지 가져오기
  String getOfflineMessage(String context) {
    switch (context) {
      case 'new_puzzle':
        return '새 퍼즐은 온라인에서만 다운로드 가능합니다.\n인터넷 연결을 확인해주세요.';
      case 'profile_update':
        return '오프라인 모드 - 프로필 업데이트는 나중에 동기화됩니다.';
      case 'puzzle_completion':
        return '오프라인 모드 - 퍼즐 완료는 나중에 동기화됩니다.';
      case 'general':
        return '오프라인 모드 - 일부 기능이 제한됩니다.';
      default:
        return '오프라인 모드입니다.';
    }
  }

  /// 온라인 상태 복구 시 처리
  Future<void> onOnlineRestored() async {
    developer.log('온라인 상태 복구 감지', name: 'OfflineManager');

    try {
      // 지연된 동기화 실행
      await _syncManager.processDelayedSync();
      developer.log('온라인 복구 시 지연 동기화 완료', name: 'OfflineManager');
    } catch (e) {
      developer.log('온라인 복구 시 동기화 실패: $e', name: 'OfflineManager');
    }
  }

  /// 현재 온라인 상태 확인
  bool get isOnline => _networkService.isOnline;

  /// 동기화 큐 상태 확인
  bool get hasPendingSync => !_syncManager.isQueueEmpty;
  int get pendingSyncCount => _syncManager.queueSize;

  /// 동기화 진행 중인지 확인
  bool get isSyncProcessing => _syncManager.isProcessing;
}

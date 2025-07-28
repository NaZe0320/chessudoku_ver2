import 'dart:async';
import 'dart:developer' as developer;
import '../network/network_service.dart';
import 'sync_queue.dart';
import 'sync_strategy.dart';

/// 전체 동기화를 관리하는 매니저
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final NetworkService _networkService = NetworkService();
  final SyncQueue _syncQueue = SyncQueue();

  StreamSubscription<bool>? _networkSubscription;
  bool _isInitialized = false;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 네트워크 서비스 초기화
      await _networkService.initialize();

      // 동기화 큐 초기화
      await _syncQueue.initialize();

      // 네트워크 상태 변화 모니터링
      _networkSubscription = _networkService.connectionStatusStream.listen(
        (bool isOnline) {
          _onNetworkStatusChanged(isOnline);
        },
      );

      _isInitialized = true;
      developer.log('동기화 매니저 초기화 완료', name: 'SyncManager');
    } catch (e) {
      developer.log('동기화 매니저 초기화 실패: $e', name: 'SyncManager');
    }
  }

  /// 네트워크 상태 변화 처리
  void _onNetworkStatusChanged(bool isOnline) {
    if (isOnline) {
      developer.log('온라인 상태 감지 - 지연 동기화 시작', name: 'SyncManager');
      _processDelayedSync();
    } else {
      developer.log('오프라인 상태 감지', name: 'SyncManager');
    }
  }

  /// 지연 동기화 처리
  Future<void> _processDelayedSync() async {
    if (_syncQueue.isEmpty) return;

    developer.log('지연 동기화 처리 시작', name: 'SyncManager');
    await _syncQueue.processQueue();
  }

  /// 즉시 동기화 작업 추가
  Future<void> addImmediateTask(SyncTask task) async {
    if (!_networkService.isOnline) {
      throw Exception('온라인 상태가 아닙니다. 즉시 동기화를 위해 온라인 연결이 필요합니다.');
    }

    developer.log('즉시 동기화 작업 추가: ${task.description}', name: 'SyncManager');
    await _processImmediateTask(task);
  }

  /// 지연 동기화 작업 추가
  Future<void> addDelayedTask(SyncTask task) async {
    developer.log('지연 동기화 작업 추가: ${task.description}', name: 'SyncManager');
    await _syncQueue.add(task);
  }

  /// 즉시 동기화 작업 처리
  Future<void> _processImmediateTask(SyncTask task) async {
    try {
      developer.log('즉시 동기화 작업 처리 중: ${task.description}', name: 'SyncManager');

      // TODO: 실제 즉시 동기화 로직 구현
      // 여기서 각 작업 타입에 따른 실제 동기화를 수행
      await Future.delayed(const Duration(milliseconds: 300)); // 임시 지연

      developer.log('즉시 동기화 작업 완료: ${task.description}', name: 'SyncManager');
    } catch (e) {
      developer.log('즉시 동기화 작업 실패: ${task.description} - $e',
          name: 'SyncManager');
      rethrow;
    }
  }

  /// 프로필 업데이트 동기화
  Future<void> syncProfileUpdate(Map<String, dynamic> profileData) async {
    final task = SyncTask(
      type: SyncTaskType.profileUpdate,
      strategy: SyncStrategy.delayed,
      data: profileData,
    );

    await addDelayedTask(task);
  }

  /// 퍼즐 완료 동기화
  Future<void> syncPuzzleCompletion(Map<String, dynamic> puzzleData) async {
    final task = SyncTask(
      type: SyncTaskType.puzzleCompletion,
      strategy: SyncStrategy.delayed,
      data: puzzleData,
    );

    await addDelayedTask(task);
  }

  /// 게임 진행 데이터 동기화
  Future<void> syncGameProgress(Map<String, dynamic> gameData) async {
    final task = SyncTask(
      type: SyncTaskType.gameProgress,
      strategy: SyncStrategy.delayed,
      data: gameData,
    );

    await addDelayedTask(task);
  }

  /// 설정 변경 동기화
  Future<void> syncSettingsChange(Map<String, dynamic> settingsData) async {
    final task = SyncTask(
      type: SyncTaskType.settingsChange,
      strategy: SyncStrategy.delayed,
      data: settingsData,
    );

    await addDelayedTask(task);
  }

  /// 현재 온라인 상태 확인
  bool get isOnline => _networkService.isOnline;

  /// 동기화 큐 상태 확인
  bool get isQueueEmpty => _syncQueue.isEmpty;
  int get queueSize => _syncQueue.size;
  bool get isProcessing => _syncQueue.isProcessing;

  /// 동기화 큐 스트림
  Stream<List<SyncTask>> get queueStream => _syncQueue.queueStream;

  /// 수동으로 지연 동기화 실행
  Future<void> processDelayedSync() async {
    if (!isOnline) {
      throw Exception('오프라인 상태입니다. 온라인 연결이 필요합니다.');
    }
    await _processDelayedSync();
  }

  /// 리소스 정리
  void dispose() {
    _networkSubscription?.cancel();
    _syncQueue.dispose();
    _isInitialized = false;
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_queue.dart';
import 'sync_strategy.dart';
import '../../data/services/api_service.dart';

/// 전체 동기화를 관리하는 매니저
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final SyncQueue _syncQueue = SyncQueue();
  ApiService? _apiService;

  StreamSubscription<ConnectivityResult>? _networkSubscription;
  bool _isInitialized = false;

  /// ApiService 설정
  ///
  /// ⚠️ 주의: AppInitializer에서 반드시 호출해야 함
  void setApiService(ApiService apiService) {
    _apiService = apiService;
    _syncQueue.setApiService(apiService);
  }

  /// 초기화
  ///
  /// 네트워크 서비스와 동기화 큐를 초기화하고
  /// 네트워크 상태 변화를 모니터링합니다.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 동기화 큐 초기화
      await _syncQueue.initialize();

      // 네트워크 상태 변화 모니터링 (간소화)
      _networkSubscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) {
          final isOnline = result != ConnectivityResult.none;
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
  ///
  /// 온라인 상태가 되면 지연된 동기화 작업들을 처리합니다.
  void _onNetworkStatusChanged(bool isOnline) {
    if (isOnline) {
      developer.log('온라인 상태 감지 - 지연 동기화 시작', name: 'SyncManager');
      _processDelayedSync();
    } else {
      developer.log('오프라인 상태 감지', name: 'SyncManager');
    }
  }

  /// 지연 동기화 처리
  ///
  /// 큐에 저장된 모든 동기화 작업을 처리합니다.
  Future<void> _processDelayedSync() async {
    if (_syncQueue.isEmpty) return;

    developer.log('지연 동기화 처리 시작', name: 'SyncManager');
    await _syncQueue.processQueue();
  }

  /// 즉시 동기화 작업 추가
  ///
  /// ⚠️ 주의: 온라인 상태에서만 사용 가능
  /// 네트워크 오류 시 예외가 발생합니다.
  Future<void> addImmediateTask(SyncTask task) async {
    developer.log('즉시 동기화 작업 추가: ${task.description}', name: 'SyncManager');

    final connectivity = Connectivity();
    final isOnline =
        await connectivity.checkConnectivity() != ConnectivityResult.none;

    if (!isOnline) {
      developer.log('오프라인 상태 - 즉시 동기화를 큐에 저장', name: 'SyncManager');
      await addDelayedTask(task);
      return;
    }

    await _processImmediateTask(task);
  }

  /// 지연 동기화 작업 추가
  ///
  /// 오프라인 상태에서도 안전하게 사용 가능합니다.
  /// 작업은 큐에 저장되어 네트워크 복구 시 자동 처리됩니다.
  Future<void> addDelayedTask(SyncTask task) async {
    developer.log('지연 동기화 작업 추가: ${task.description}', name: 'SyncManager');
    await _syncQueue.add(task);
  }

  /// 즉시 동기화 작업 처리
  ///
  /// 네트워크 상태를 확인하고 즉시 HTTP API에 동기화합니다.
  Future<void> _processImmediateTask(SyncTask task) async {
    try {
      developer.log('즉시 동기화 작업 처리 중: ${task.description}', name: 'SyncManager');

      // 네트워크 상태 재확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('즉시 동기화 중 오프라인 상태 감지 - 큐에 저장', name: 'SyncManager');
        await addDelayedTask(task);
        return;
      }

      switch (task.type) {
        case SyncTaskType.profileUpdate:
          await _processProfileUpdateImmediate(task.data);
          break;
      }

      developer.log('즉시 동기화 작업 완료: ${task.description}', name: 'SyncManager');
    } catch (e) {
      developer.log('즉시 동기화 작업 실패: ${task.description} - $e',
          name: 'SyncManager');

      // 네트워크 오류인 경우 큐에 저장
      if (_isNetworkError(e)) {
        developer.log('네트워크 오류로 인한 실패 - 큐에 저장', name: 'SyncManager');
        await addDelayedTask(task);
      } else {
        rethrow;
      }
    }
  }

  /// 네트워크 오류인지 확인
  bool _isNetworkError(dynamic error) {
    if (error is Exception) {
      final message = error.toString().toLowerCase();
      return message.contains('network') ||
          message.contains('connection') ||
          message.contains('timeout') ||
          message.contains('offline');
    }
    return false;
  }

  /// 즉시 프로필 업데이트 처리 (HTTP API 사용)
  Future<void> _processProfileUpdateImmediate(Map<String, dynamic> data) async {
    developer.log('즉시 프로필 업데이트 처리 시작', name: 'SyncManager');

    if (_apiService == null) {
      developer.log('ApiService가 설정되지 않음', name: 'SyncManager');
      throw Exception('ApiService가 설정되지 않았습니다.');
    }

    final deviceId = data['deviceId'] as String;
    developer.log('즉시 프로필 업데이트 처리 중: $deviceId', name: 'SyncManager');

    try {
      // 계정 생성 또는 업데이트
      await _createOrUpdateAccount(deviceId, data);
      developer.log('즉시 프로필 업데이트 완료: $deviceId', name: 'SyncManager');
    } catch (e) {
      developer.log('즉시 프로필 업데이트 실패: $deviceId - $e', name: 'SyncManager');
      rethrow;
    }
  }

  /// 계정 생성 또는 업데이트 (HTTP API 사용)
  Future<void> _createOrUpdateAccount(
      String deviceId, Map<String, dynamic> data) async {
    try {
      // 먼저 기존 계정이 있는지 확인
      try {
        await _apiService!.get('/account/$deviceId');
        // 기존 계정이 있으면 업데이트
        developer.log('기존 계정 발견, 업데이트 진행: $deviceId', name: 'SyncManager');

        final updateData = {
          'username': data['username'] ?? 'Player',
          'total_play_time': data['totalPlayTime'] ?? 0,
          'completed_puzzles': data['completedPuzzles'] ?? 0,
          'current_streak': data['currentStreak'] ?? 0,
          'best_streak': data['bestStreak'] ?? 0,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _apiService!.put('/account/$deviceId', data: updateData);
        developer.log('계정 업데이트 완료: $deviceId', name: 'SyncManager');
      } catch (e) {
        // 기존 계정이 없으면 생성
        developer.log('기존 계정 없음, 새로 생성: $deviceId', name: 'SyncManager');

        final createData = {
          'device_id': deviceId,
        };

        await _apiService!.post('/account/register', data: createData);
        developer.log('계정 생성 완료: $deviceId', name: 'SyncManager');
      }
    } catch (e) {
      developer.log('계정 생성/업데이트 실패: $deviceId - $e', name: 'SyncManager');
      rethrow;
    }
  }

  /// 프로필 업데이트 동기화 (로컬 → 서버 백업)
  ///
  /// 로컬 사용자 프로필 데이터를 서버에 백업합니다.
  /// 오프라인 상태에서는 큐에 저장되어 나중에 처리됩니다.
  Future<void> syncProfileUpdate(Map<String, dynamic> profileData) async {
    final task = SyncTask(
      type: SyncTaskType.profileUpdate,
      strategy: SyncStrategy.delayed,
      data: profileData,
    );

    await addDelayedTask(task);
  }

  /// 서버에서 프로필 데이터 가져오기 (HTTP API 사용)
  ///
  /// 서버에 저장된 사용자 프로필 데이터를 가져옵니다.
  /// 온라인 상태에서만 사용 가능합니다.
  Future<Map<String, dynamic>?> getServerProfile(String deviceId) async {
    try {
      developer.log('서버에서 프로필 데이터 가져오기 시작: $deviceId', name: 'SyncManager');

      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('오프라인 상태 - 서버 데이터 가져오기 불가', name: 'SyncManager');
        return null;
      }

      if (_apiService == null) {
        developer.log('ApiService가 설정되지 않음', name: 'SyncManager');
        return null;
      }

      final response = await _apiService!.get('/account/$deviceId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          final accountData =
              responseData['data']['account'] as Map<String, dynamic>;

          // API 응답을 기존 형식으로 변환
          final profileData = {
            'deviceId': accountData['device_id'] ?? deviceId,
            'username': accountData['username'] ?? 'Player',
            'createdAt':
                accountData['created_at'] ?? DateTime.now().toIso8601String(),
            'lastLoginAt': accountData['last_login_at'] ??
                DateTime.now().toIso8601String(),
            'totalPlayTime': accountData['total_play_time'] ?? 0,
            'completedPuzzles': accountData['completed_puzzles'] ?? 0,
            'currentStreak': accountData['current_streak'] ?? 0,
            'bestStreak': accountData['best_streak'] ?? 0,
          };

          developer.log('서버에서 프로필 데이터 발견: $deviceId', name: 'SyncManager');
          return profileData;
        } else {
          developer.log('서버 응답 형식 오류: $deviceId', name: 'SyncManager');
          return null;
        }
      } else if (response.statusCode == 404) {
        developer.log('서버에 프로필 데이터 없음: $deviceId', name: 'SyncManager');
        return null;
      } else {
        developer.log('서버 응답 오류: ${response.statusCode}', name: 'SyncManager');
        return null;
      }
    } catch (e) {
      developer.log('서버에서 프로필 데이터 가져오기 실패: $deviceId - $e',
          name: 'SyncManager');
      return null;
    }
  }

  /// 현재 온라인 상태 확인
  Future<bool> get isOnline async {
    final connectivity = Connectivity();
    return await connectivity.checkConnectivity() != ConnectivityResult.none;
  }

  /// 동기화 큐 상태 확인
  bool get isQueueEmpty => _syncQueue.isEmpty;
  int get queueSize => _syncQueue.size;
  bool get isProcessing => _syncQueue.isProcessing;

  /// 동기화 큐 스트림
  ///
  /// 큐 상태 변화를 실시간으로 모니터링할 수 있습니다.
  Stream<List<SyncTask>> get queueStream => _syncQueue.queueStream;

  /// 수동으로 지연 동기화 실행
  ///
  /// ⚠️ 주의: 온라인 상태에서만 사용 가능
  /// 네트워크 오류 시 예외가 발생합니다.
  Future<void> processDelayedSync() async {
    final online = await isOnline;
    if (!online) {
      throw Exception('오프라인 상태입니다. 온라인 연결이 필요합니다.');
    }
    await _processDelayedSync();
  }

  /// 리소스 정리
  ///
  /// 앱 종료 시 반드시 호출해야 합니다.
  void dispose() {
    _networkSubscription?.cancel();
    _syncQueue.dispose();
    _isInitialized = false;
  }
}

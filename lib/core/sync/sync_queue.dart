import 'dart:async';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'sync_strategy.dart';
import '../../data/services/firestore_service.dart';

/// 지연 동기화를 위한 큐 시스템
class SyncQueue {
  static final SyncQueue _instance = SyncQueue._internal();
  factory SyncQueue() => _instance;
  SyncQueue._internal();

  final List<SyncTask> _queue = [];
  final StreamController<List<SyncTask>> _queueController =
      StreamController<List<SyncTask>>.broadcast();

  bool _isProcessing = false;
  static const String _queueKey = 'sync_queue';
  FirestoreService? _firestoreService;

  /// FirestoreService 설정
  void setFirestoreService(FirestoreService firestoreService) {
    _firestoreService = firestoreService;
  }

  /// 큐에 작업 추가
  Future<void> add(SyncTask task) async {
    _queue.add(task);
    await _saveQueue();
    _queueController.add(_queue);

    developer.log('동기화 큐에 작업 추가: ${task.description}', name: 'SyncQueue');
  }

  /// 큐에서 작업 제거
  Future<void> remove(SyncTask task) async {
    _queue.remove(task);
    await _saveQueue();
    _queueController.add(_queue);
  }

  /// 큐의 모든 작업 가져오기
  List<SyncTask> get allTasks => List.unmodifiable(_queue);

  /// 큐 스트림
  Stream<List<SyncTask>> get queueStream => _queueController.stream;

  /// 큐가 비어있는지 확인
  bool get isEmpty => _queue.isEmpty;

  /// 큐 크기
  int get size => _queue.length;

  /// 큐 처리 중인지 확인
  bool get isProcessing => _isProcessing;

  /// 큐 초기화 (저장된 데이터 로드)
  Future<void> initialize() async {
    try {
      await _loadQueue();
      developer.log('동기화 큐 초기화 완료: ${_queue.length}개 작업', name: 'SyncQueue');
    } catch (e) {
      developer.log('동기화 큐 초기화 실패: $e', name: 'SyncQueue');
    }
  }

  /// 큐 처리 시작
  Future<void> processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    developer.log('동기화 큐 처리 시작: ${_queue.length}개 작업', name: 'SyncQueue');

    try {
      final tasksToProcess = List<SyncTask>.from(_queue);

      for (final task in tasksToProcess) {
        try {
          await _processTask(task);
          await remove(task);
        } catch (e) {
          developer.log('작업 처리 실패: ${task.description} - $e',
              name: 'SyncQueue');

          // 재시도 횟수 증가
          final retryTask = task.incrementRetry();
          if (retryTask.retryCount < 5) {
            await remove(task);
            await add(retryTask);
          } else {
            // 최대 재시도 횟수 초과 시 제거
            await remove(task);
            developer.log('작업 최대 재시도 횟수 초과: ${task.description}',
                name: 'SyncQueue');
          }
        }
      }
    } finally {
      _isProcessing = false;
      developer.log('동기화 큐 처리 완료', name: 'SyncQueue');
    }
  }

  /// 개별 작업 처리 (개선된 버전)
  Future<void> _processTask(SyncTask task) async {
    developer.log('작업 처리 중: ${task.description}', name: 'SyncQueue');

    try {
      // 작업 타입별 실제 동기화 로직
      switch (task.type) {
        case SyncTaskType.profileUpdate:
          await _processProfileUpdate(task.data);
          break;
      }

      developer.log('작업 처리 완료: ${task.description}', name: 'SyncQueue');
    } catch (e) {
      developer.log('작업 처리 실패: ${task.description} - $e', name: 'SyncQueue');

      // 네트워크 오류인지 확인
      if (_isNetworkError(e)) {
        developer.log('네트워크 오류로 인한 실패 - 재시도 대기', name: 'SyncQueue');
        // 네트워크 오류는 나중에 재시도
        rethrow;
      } else {
        // 다른 오류는 즉시 실패 처리
        developer.log('시스템 오류로 인한 실패 - 재시도하지 않음', name: 'SyncQueue');
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

  /// 프로필 업데이트 처리
  Future<void> _processProfileUpdate(Map<String, dynamic> data) async {
    developer.log('프로필 업데이트 처리 시작', name: 'SyncQueue');

    if (_firestoreService == null) {
      developer.log('FirestoreService가 설정되지 않음', name: 'SyncQueue');
      throw Exception('FirestoreService가 설정되지 않았습니다.');
    }

    final deviceId = data['deviceId'] as String;
    developer.log('프로필 업데이트 처리 중: $deviceId', name: 'SyncQueue');

    try {
      await _firestoreService!.createOrUpdateUser(deviceId, data);
      developer.log('프로필 업데이트 동기화 완료: $deviceId', name: 'SyncQueue');
    } catch (e) {
      developer.log('프로필 업데이트 동기화 실패: $deviceId - $e', name: 'SyncQueue');
      rethrow;
    }
  }

  /// 큐를 SharedPreferences에 저장
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueData = _queue
          .map((task) => {
                'type': task.type.index,
                'strategy': task.strategy.index,
                'data': task.data,
                'createdAt': task.createdAt.toIso8601String(),
                'retryCount': task.retryCount,
              })
          .toList();

      await prefs.setString(_queueKey, jsonEncode(queueData));
    } catch (e) {
      developer.log('큐 저장 실패: $e', name: 'SyncQueue');
    }
  }

  /// SharedPreferences에서 큐 로드
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueString = prefs.getString(_queueKey);

      if (queueString != null) {
        final queueData = jsonDecode(queueString) as List;
        _queue.clear();

        for (final taskData in queueData) {
          final task = SyncTask(
            type: SyncTaskType.values[taskData['type']],
            strategy: SyncStrategy.values[taskData['strategy']],
            data: Map<String, dynamic>.from(taskData['data']),
            createdAt: DateTime.parse(taskData['createdAt']),
            retryCount: taskData['retryCount'],
          );
          _queue.add(task);
        }
      }
    } catch (e) {
      developer.log('큐 로드 실패: $e', name: 'SyncQueue');
    }
  }

  /// 큐 초기화
  Future<void> clear() async {
    _queue.clear();
    await _saveQueue();
    _queueController.add(_queue);
    developer.log('동기화 큐 초기화 완료', name: 'SyncQueue');
  }

  /// 리소스 정리
  void dispose() {
    _queueController.close();
  }
}

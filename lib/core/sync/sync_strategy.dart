/// 동기화 전략 타입
enum SyncStrategy {
  /// 즉시 동기화 (온라인 필수)
  immediate,

  /// 지연 동기화 (오프라인 가능, 나중에 동기화)
  delayed,
}

/// 동기화 작업 타입
enum SyncTaskType {
  /// 프로필 업데이트
  profileUpdate,

  /// 퍼즐 완료
  puzzleCompletion,

  /// 게임 진행 데이터
  gameProgress,

  /// 설정 변경
  settingsChange,
}

/// 동기화 작업 정보
class SyncTask {
  final SyncTaskType type;
  final SyncStrategy strategy;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncTask({
    required this.type,
    required this.strategy,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 재시도 횟수 증가
  SyncTask incrementRetry() {
    return SyncTask(
      type: type,
      strategy: strategy,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount + 1,
    );
  }

  /// 작업 설명
  String get description {
    switch (type) {
      case SyncTaskType.profileUpdate:
        return '프로필 업데이트';
      case SyncTaskType.puzzleCompletion:
        return '퍼즐 완료';
      case SyncTaskType.gameProgress:
        return '게임 진행 데이터';
      case SyncTaskType.settingsChange:
        return '설정 변경';
    }
  }

  @override
  String toString() {
    return 'SyncTask(type: $type, strategy: $strategy, retryCount: $retryCount)';
  }
}

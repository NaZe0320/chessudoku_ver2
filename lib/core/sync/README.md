# 동기화 시스템 가이드

## 🎯 개요

CheSudoku 앱의 모든 데이터 동기화는 `SyncManager`를 통해 처리됩니다. 이는 일관성, 안정성, 그리고 사용자 경험을 보장하기 위한 중앙화된 동기화 시스템입니다.

## 📋 동기화 규칙

### ✅ 올바른 사용법

```dart
// 1. Repository에서 SyncManager 주입
class UserProfileRepositoryImpl implements UserProfileRepository {
  final SyncManager _syncManager = SyncManager();
  
  // 2. 데이터 변경 시 로컬 DB 즉시 업데이트
  await _databaseService.update(/* 로컬 업데이트 */);
  
  // 3. SyncManager를 통한 서버 동기화
  await _syncManager.syncProfileUpdate(profileData);
}
```

### ❌ 금지된 사용법

```dart
// 직접 Firestore 호출 금지
await _firestoreService.createOrUpdateUser(deviceId, data);
await _firestoreService.getUserData(deviceId);

// 직접 네트워크 상태 확인 금지
if (_networkService.isOnline) {
  // 직접 동기화 로직
}
```

## 🔄 동기화 흐름

### 데이터 변경 시
```
Repository (비즈니스 로직)
    ↓
로컬 DB 업데이트 (즉시)
    ↓
SyncManager.syncXXX() 호출
    ↓
SyncQueue에 작업 추가
    ↓
네트워크 상태에 따라 처리
    ↓
Firestore 동기화 (백그라운드)
```

### 데이터 조회 시
```
Repository.getXXX()
    ↓
로컬 DB 조회 (즉시)
    ↓
온라인인 경우 SyncManager를 통한 서버 동기화
    ↓
최신 데이터 반환
```

## 📱 네트워크 상태별 동작

### 온라인 상태
- **즉시 동기화**: `SyncManager.addImmediateTask()`
- **지연 동기화**: `SyncManager.syncXXX()` (기본)
- **자동 처리**: 네트워크 상태 변화 감지 시 자동 동기화

### 오프라인 상태
- **로컬 저장**: SharedPreferences에 동기화 작업 저장
- **지연 처리**: 네트워크 복구 시 자동 처리
- **재시도**: 최대 5회까지 자동 재시도

## 🛠️ 사용법

### 1. 프로필 업데이트 동기화

```dart
await _syncManager.syncProfileUpdate({
  'deviceId': profile.deviceId,
  'username': profile.username,
  'completedPuzzles': profile.completedPuzzles,
  'currentStreak': profile.currentStreak,
  'bestStreak': profile.bestStreak,
  'totalPlayTime': profile.totalPlayTime,
});
```

### 2. 퍼즐 완료 동기화

```dart
await _syncManager.syncPuzzleCompletion({
  'deviceId': deviceId,
  'completedAt': DateTime.now().toIso8601String(),
  'completedPuzzles': newCompletedPuzzles,
});
```

### 3. 게임 진행 데이터 동기화

```dart
await _syncManager.syncGameProgress({
  'deviceId': deviceId,
  'gameState': gameState,
  'progress': progress,
});
```

### 4. 설정 변경 동기화

```dart
await _syncManager.syncSettingsChange({
  'deviceId': deviceId,
  'language': language,
  'theme': theme,
});
```

## 🔧 초기화

### AppInitializer에서 설정

```dart
// FirestoreService 설정
_syncManager.setFirestoreService(_firestoreService);

// SyncManager 초기화
await _syncManager.initialize();
```

## 📊 상태 확인

### 동기화 상태 모니터링

```dart
// 온라인 상태 확인
bool isOnline = _syncManager.isOnline;

// 큐 상태 확인
bool isEmpty = _syncManager.isQueueEmpty;
int size = _syncManager.queueSize;
bool isProcessing = _syncManager.isProcessing;

// 큐 스트림 구독
_syncManager.queueStream.listen((tasks) {
  print('대기 중인 동기화 작업: ${tasks.length}개');
});
```

## ⚠️ 주의사항

### 1. 데이터 일관성
- 로컬 DB 업데이트는 **즉시** 수행
- 서버 동기화는 **백그라운드**에서 처리
- 사용자 경험을 위해 UI는 즉시 반영

### 2. 에러 처리
- 네트워크 오류는 자동 재시도
- 시스템 오류는 즉시 실패 처리
- 최대 재시도 횟수: 5회

### 3. 메모리 관리
- 앱 종료 시 `_syncManager.dispose()` 호출
- 큐 데이터는 SharedPreferences에 영구 저장

## 🎯 장점

### 1. 일관성
- 모든 동기화가 동일한 방식으로 처리
- 중앙화된 동기화 관리

### 2. 안정성
- 오프라인 상태에서도 안전한 데이터 저장
- 네트워크 복구 시 자동 동기화

### 3. 확장성
- 새로운 동기화 타입 추가 용이
- 플러그인 방식의 동기화 처리

### 4. 사용자 경험
- 네트워크 상태에 관계없이 즉시 UI 반영
- 백그라운드에서 자동 동기화

## 📝 예시 코드

### Repository 구현 예시

```dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  final SyncManager _syncManager = SyncManager();
  
  @override
  Future<void> incrementCompletedPuzzles() async {
    // 1. 로컬 DB 즉시 업데이트
    await _databaseService.update(/* 업데이트 로직 */);
    
    // 2. SyncManager를 통한 동기화
    await _syncManager.syncProfileUpdate(profileData);
    await _syncManager.syncPuzzleCompletion(puzzleData);
  }
}
```

이 가이드를 따라 모든 동기화를 SyncManager를 통해 처리하면 일관되고 안정적인 동기화 시스템을 유지할 수 있습니다. 
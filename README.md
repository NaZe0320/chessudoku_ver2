# CheSudoku

체스와 스도쿠를 결합한 퍼즐 게임 Flutter 앱입니다.

## 🎯 프로젝트 개요

CheSudoku는 MVI 패턴과 Riverpod를 사용하여 개발된 Flutter 앱으로, 체스 기물의 움직임을 활용한 스도쿠 퍼즐을 제공합니다.

## 🏗️ 아키텍처

### MVI (Model-View-Intent) 구조
```
lib/
├── core/           # 핵심 유틸리티 및 베이스 클래스
├── data/           # 데이터 레이어 (API, DB, 모델)
├── domain/         # 도메인 레이어 (Intent, State, Notifier)
└── ui/             # 프레젠테이션 레이어 (View/Widget)
```

### 동기화 시스템
모든 데이터 동기화는 `SyncManager`를 통해 중앙화되어 관리됩니다.

#### 동기화 규칙
- ✅ **SyncManager를 통한 동기화**: `await _syncManager.syncProfileUpdate(data)`
- ❌ **직접 Firestore 호출 금지**: `await _firestoreService.createOrUpdateUser()`
- ✅ **로컬 DB 즉시 업데이트**: UI 반영을 위한 즉시 처리
- ✅ **서버 동기화 백그라운드**: 네트워크 상태에 따른 지연 처리

#### 네트워크 상태별 동작
- **온라인**: 즉시 또는 지연 동기화
- **오프라인**: 큐에 저장, 네트워크 복구 시 자동 처리

자세한 동기화 가이드는 [lib/core/sync/README.md](lib/core/sync/README.md)를 참조하세요.

## 🚀 시작하기

### 필수 요구사항
- Flutter 3.0+
- Dart 3.0+
- Firebase 프로젝트 설정

### 설치 및 실행
```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 📱 주요 기능

- 체스 기물을 활용한 스도쿠 퍼즐
- 오프라인 지원 및 데이터 동기화
- 다국어 지원 (한국어, 영어)
- 사용자 진행 상황 추적
- 데일리 챌린지

## 🔧 개발 가이드

### 코딩 스타일
- **Linting**: `flutter_lints` 규칙 준수
- **Naming**: 
  - 클래스: `PascalCase`
  - 변수/함수: `camelCase`
  - 파일명: `snake_case`

### 상태 관리 (Riverpod)
- **Provider 네이밍**: `[name]Provider`
- **StateNotifier**: `[name]Notifier`
- **State 클래스**: `[name]State`

### 동기화 시스템 사용법
```dart
// Repository에서 SyncManager 사용
class UserProfileRepositoryImpl {
  final SyncManager _syncManager = SyncManager();
  
  Future<void> updateProfile() async {
    // 1. 로컬 DB 즉시 업데이트
    await _databaseService.update(/* 업데이트 */);
    
    // 2. SyncManager를 통한 서버 동기화
    await _syncManager.syncProfileUpdate(profileData);
  }
}
```

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

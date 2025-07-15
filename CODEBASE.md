# 체스도쿠 (ChessSudoku) 코드베이스 문서

## 📋 프로젝트 개요

체스도쿠는 전통적인 스도쿠 퍼즐에 체스 기물의 공격 규칙을 결합한 새로운 형태의 퍼즐 게임입니다. Flutter로 개발되었으며, Clean Architecture 패턴을 적용하여 유지보수성과 확장성을 고려한 구조로 설계되었습니다.

### 게임 규칙
1. **기본 스도쿠 규칙**: 1-9 숫자가 각 행, 열, 3x3 박스에서 중복되지 않아야 함
2. **체스 기물 규칙**: 체스 기물이 공격할 수 있는 모든 위치에는 같은 숫자가 올 수 없음
3. **체스 기물 종류**: 킹, 퀸, 룩, 비숍, 나이트

## 🏗️ 아키텍처 구조

### Clean Architecture 적용
프로젝트는 3계층 구조로 설계되어 있습니다:

```
┌─────────────────┐
│   UI Layer      │ ← 사용자 인터페이스 및 상태 관리
├─────────────────┤
│ Domain Layer    │ ← 비즈니스 로직 및 추상화
├─────────────────┤
│  Data Layer     │ ← 데이터 소스 및 구현체
└─────────────────┘
```

### 의존성 방향
- **UI → Domain → Data** (단방향 의존성)
- Domain Layer는 추상화(인터페이스)만 정의
- Data Layer에서 Domain의 인터페이스를 구현

## 📁 폴더 구조

### lib/ 디렉토리
```
lib/
├── core/                    # 핵심 유틸리티 및 공통 기능
│   ├── base/               # 기본 클래스 (BaseNotifier, BaseIntent)
│   ├── di/                 # 의존성 주입 설정
│   └── utils/              # 체스도쿠 알고리즘 (생성기, 풀이기, 검증기)
├── data/                   # 데이터 계층
│   ├── models/             # 데이터 모델
│   ├── repositories/       # Repository 구현체
│   └── services/           # 외부 서비스 (API, DB, 캐시)
├── domain/                 # 도메인 계층
│   ├── enums/              # 열거형 (난이도, 체스 기물 등)
│   ├── intents/            # 사용자 의도 정의
│   ├── notifiers/          # 상태 관리 노티파이어
│   ├── repositories/       # Repository 인터페이스
│   └── states/             # 상태 클래스
├── ui/                     # UI 계층
│   ├── common/             # 공통 위젯
│   ├── screens/            # 화면별 UI
│   └── theme/              # 테마 및 스타일
├── legacy/                 # 사용하지 않는 탭 관련 코드
└── main.dart               # 앱 진입점
```

### legacy/ 디렉토리 (사용 안함)

## 🎯 주요 기능 및 구현

### 1. 게임 엔진 (Core Utils)

#### ChessSudokuGenerator
- **위치**: `lib/core/utils/chess_sudoku_generator.dart`
- **역할**: 체스도쿠 퍼즐 생성
- **주요 기능**:
  - 난이도별 체스 기물 배치
  - 백트래킹 알고리즘으로 완전한 해 생성
  - 빈칸 뚫기 알고리즘으로 퍼즐 생성
  - 풀이 가능성 검증

#### ChessSudokuSolver
- **위치**: `lib/core/utils/chess_sudoku_solver.dart`
- **역할**: 체스도쿠 퍼즐 풀이
- **주요 기능**:
  - MRV(Minimum Remaining Values) 휴리스틱
  - 제약 전파 (Constraint Propagation)
  - 백트래킹 알고리즘
  - 풀이 실패 원인 분석

#### ChessSudokuValidator
- **위치**: `lib/core/utils/chess_sudoku_validator.dart`
- **역할**: 체스도쿠 규칙 검증
- **주요 기능**:
  - 기본 스도쿠 규칙 검증 (행, 열, 3x3 박스)
  - 체스 기물 공격 규칙 검증
  - 보드 유효성 검사

### 2. 상태 관리 (Domain Layer)

#### Intent-Notifier 패턴
- **Intent**: 사용자의 의도를 나타내는 불변 객체
- **Notifier**: Intent를 받아 State를 변경하는 로직
- **State**: 불변 상태 객체

예시:
```dart
// Intent 정의
abstract class GameIntent {}
class SelectCellIntent extends GameIntent {
  final int row, col;
  SelectCellIntent(this.row, this.col);
}

// State 정의
class GameState {
  final String gameId;
  final List<List<CellContent>> board;
  final int? selectedRow, selectedCol;
  // ...
}

// Notifier 정의
class GameNotifier extends StateNotifier<GameState> {
  void handleIntent(GameIntent intent) {
    if (intent is SelectCellIntent) {
      _selectCell(intent.row, intent.col);
    }
  }
}
```

#### 주요 Notifiers
1. **GameNotifier**: 게임 상태 관리 (셀 선택, 숫자 입력, 게임 진행)
2. **LanguagePackNotifier**: 다국어 지원
3. **FilterNotifier**: 필터링 기능

### 3. 데이터 모델 (Data Layer)

#### CellContent
- **위치**: `lib/data/models/cell_content.dart`
- **역할**: 게임 보드의 각 셀 정보
- **속성**:
  - `number`: 1-9 숫자
  - `chessPiece`: 체스 기물
  - `isInitial`: 초기값 여부 (수정 불가)
  - `notes`: 메모 숫자들

### 4. 서비스 레이어

#### DatabaseService
- **위치**: `lib/data/services/database_service.dart`
- **역할**: SQLite 데이터베이스 관리
- **기능**: 설정 저장

#### ApiService
- **위치**: `lib/data/services/api_service.dart`
- **역할**: 서버 통신 (Dio 기반)
- **기능**: 사용자 정보

#### CacheService
- **위치**: `lib/data/services/cache_service.dart`
- **역할**: 로컬 캐시 관리 (SharedPreferences)
- **기능**: 설정 값, 임시 데이터 저장

### 5. UI 구조

#### 화면 구성 (탭 제거 후)
1. **HomeScreen**: 메인 홈 화면 (오늘의 도전, 연속 기록, 최근 활동 등)
2. **FriendsScreen**: 친구 목록 (소셜 기능)
3. **ProfileScreen**: 사용자 프로필 및 설정
4. **GameScreen**: 실제 게임 플레이 화면

#### 주요 위젯
- **GameController**: 게임 로직 제어
- **FilterChipGroup**: 필터링 UI
- **StatCard**: 통계 카드 위젯

## 🔧 의존성 주입 (DI)

### Provider 패턴 사용
Riverpod을 사용하여 의존성 주입 구현:

```dart
// Service Providers
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Notifier Providers
final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(initialState);
});
```

## 🌐 다국어 지원

### LanguagePack 시스템
- **LanguagePackNotifier**: 언어팩 상태 관리
- **LanguageRepository**: 언어팩 데이터 관리
- **번역 Provider**: 키-값 기반 번역 제공

```dart
final translationProvider = Provider<String Function(String, [String?])>((ref) {
  final languageState = ref.watch(languagePackNotifierProvider);
  return (String key, [String? defaultValue]) {
    return languageState.translate(key, defaultValue);
  };
});
```

## 🧪 테스트 구조

### 테스트 파일
- `test/domain/utils/`: 핵심 알고리즘 테스트
- `test/repository_test.dart`: Repository 계층 테스트
- `test/notifier_test.dart`: 상태 관리 테스트

### 테스트 전략
1. **단위 테스트**: 각 클래스의 개별 기능
2. **통합 테스트**: 여러 계층 간의 상호작용
3. **아키텍처 테스트**: 의존성 방향 검증

## 📦 주요 의존성

### 상태 관리
- `flutter_riverpod`: 상태 관리 및 DI
- `flutter_hooks`: 생명주기 관리
- `hooks_riverpod`: Riverpod + Hooks 통합

### 데이터 저장
- `sqflite`: SQLite 데이터베이스
- `shared_preferences`: 설정 저장

### 네트워킹
- `dio`: HTTP 클라이언트

### 유틸리티
- `uuid`: 고유 ID 생성
- `device_info_plus`: 디바이스 정보

## 🔄 데이터 흐름

### 전체 데이터 흐름
```
사용자 입력 → Intent → Notifier → State 변경 → UI 업데이트
     ↓
Repository → Service → 외부 데이터 소스 (DB/API)
```

### 예시: 셀 선택 흐름
1. 사용자가 셀 터치
2. `PuzzleCell`에서 `SelectCellIntent` 생성
3. `GameNotifier.handleIntent()` 호출
4. `GameState.selectedRow/Col` 업데이트
5. 관련 UI 위젯 자동 리빌드

## 🛠️ 개발 가이드라인

### 1. 새로운 기능 추가
1. Domain Layer에 Intent/State 정의
2. Notifier에 비즈니스 로직 구현
3. 필요시 Repository 인터페이스 정의
4. Data Layer에 구현체 작성
5. UI Layer에 위젯 구현
6. Provider 설정 및 DI 연결

### 2. 코드 스타일
- **네이밍**: 명확하고 의미있는 이름 사용
- **문서화**: 주요 클래스/메서드에 주석 작성
- **타입 안정성**: 제네릭과 null safety 적극 활용
- **불변성**: 가능한 한 불변 객체 사용

### 3. 상태 관리 원칙
- **단일 책임**: 각 Notifier는 하나의 관심사만 처리
- **불변 상태**: State 객체는 불변으로 설계
- **명확한 Intent**: 사용자 의도를 명확히 표현하는 Intent 정의

---

이 문서는 체스도쿠 프로젝트의 전체적인 구조와 설계 철학을 설명합니다. 각 계층과 컴포넌트가 어떻게 상호작용하는지 이해하고, 일관된 패턴을 따라 개발하는 데 도움이 되기를 바랍니다. 
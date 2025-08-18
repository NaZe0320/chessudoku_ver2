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

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

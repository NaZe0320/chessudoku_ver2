import '../../data/models/test_model.dart';

/// 테스트 데이터 상태 열거형
enum TestStatus {
  initial, // 초기 상태
  loading, // 로딩 중
  success, // 성공
  failure, // 실패
}

/// 테스트 데이터 상태 클래스
class TestState {
  final TestStatus status;
  final List<TestModel> tests;
  final TestModel? selectedTest;
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const TestState({
    this.status = TestStatus.initial,
    this.tests = const [],
    this.selectedTest,
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  /// 상태 복사본 생성
  TestState copyWith({
    TestStatus? status,
    List<TestModel>? tests,
    TestModel? selectedTest,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearSelectedTest = false,
    bool clearErrorMessage = false,
  }) {
    return TestState(
      status: status ?? this.status,
      tests: tests ?? this.tests,
      selectedTest:
          clearSelectedTest ? null : (selectedTest ?? this.selectedTest),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// 로딩 상태 확인
  bool get isLoading => status == TestStatus.loading;

  /// 성공 상태 확인
  bool get isSuccess => status == TestStatus.success;

  /// 실패 상태 확인
  bool get isFailure => status == TestStatus.failure;

  /// 초기 상태 확인
  bool get isInitial => status == TestStatus.initial;

  /// 어떤 작업이든 진행 중인지 확인
  bool get isAnyActionInProgress => isCreating || isUpdating || isDeleting;

  /// 테스트 데이터가 비어있는지 확인
  bool get isEmpty => tests.isEmpty;

  /// 테스트 데이터 개수
  int get testsCount => tests.length;

  /// 특정 ID의 테스트 데이터 찾기
  TestModel? getTestById(String id) {
    try {
      return tests.firstWhere((test) => test.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestState &&
        other.status == status &&
        other.tests == tests &&
        other.selectedTest == selectedTest &&
        other.errorMessage == errorMessage &&
        other.isCreating == isCreating &&
        other.isUpdating == isUpdating &&
        other.isDeleting == isDeleting;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        tests.hashCode ^
        selectedTest.hashCode ^
        errorMessage.hashCode ^
        isCreating.hashCode ^
        isUpdating.hashCode ^
        isDeleting.hashCode;
  }

  @override
  String toString() {
    return '''TestState(
      status: $status,
      testsCount: ${tests.length},
      selectedTest: ${selectedTest?.id},
      errorMessage: $errorMessage,
      isCreating: $isCreating,
      isUpdating: $isUpdating,
      isDeleting: $isDeleting,
    )''';
  }
}

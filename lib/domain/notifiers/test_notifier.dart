import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/test_repository.dart';
import '../../data/models/test_model.dart';
import '../states/test_state.dart';
import '../../core/di/providers.dart';

/// 테스트 데이터 관리 노티파이어
class TestNotifier extends StateNotifier<TestState> {
  final TestRepository _testRepository;

  TestNotifier(this._testRepository) : super(const TestState());

  /// 모든 테스트 데이터 로드
  Future<void> loadTests() async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: TestStatus.loading,
      clearErrorMessage: true,
    );

    try {
      debugPrint('[TestNotifier] 테스트 데이터 로드 시작');

      final tests = await _testRepository.getAllTests();

      state = state.copyWith(
        status: TestStatus.success,
        tests: tests,
      );

      debugPrint('[TestNotifier] 테스트 데이터 로드 완료: ${tests.length}개');
    } catch (e) {
      debugPrint('[TestNotifier] 테스트 데이터 로드 실패: $e');

      state = state.copyWith(
        status: TestStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// 특정 ID의 테스트 데이터 로드
  Future<void> loadTestById(String id) async {
    try {
      debugPrint('[TestNotifier] 테스트 데이터 조회 시작: $id');

      final test = await _testRepository.getTestById(id);

      if (test != null) {
        state = state.copyWith(selectedTest: test);
        debugPrint('[TestNotifier] 테스트 데이터 조회 완료: ${test.name}');
      } else {
        state = state.copyWith(
          errorMessage: '테스트 데이터를 찾을 수 없습니다.',
        );
        debugPrint('[TestNotifier] 테스트 데이터를 찾을 수 없음: $id');
      }
    } catch (e) {
      debugPrint('[TestNotifier] 테스트 데이터 조회 실패: $e');

      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  /// 새로운 테스트 데이터 생성
  Future<bool> createTest({
    required String name,
    required String description,
  }) async {
    if (state.isCreating) return false;

    state = state.copyWith(
      isCreating: true,
      clearErrorMessage: true,
    );

    try {
      debugPrint('[TestNotifier] 테스트 데이터 생성 시작: $name');

      final newTest = await _testRepository.createTest(
        name: name,
        description: description,
      );

      // 현재 리스트에 새 테스트 추가
      final updatedTests = [...state.tests, newTest];

      state = state.copyWith(
        tests: updatedTests,
        selectedTest: newTest,
        isCreating: false,
      );

      debugPrint('[TestNotifier] 테스트 데이터 생성 완료: ${newTest.id}');
      return true;
    } catch (e) {
      debugPrint('[TestNotifier] 테스트 데이터 생성 실패: $e');

      state = state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 테스트 데이터 수정
  Future<bool> updateTest({
    required String id,
    required String name,
    required String description,
  }) async {
    if (state.isUpdating) return false;

    state = state.copyWith(
      isUpdating: true,
      clearErrorMessage: true,
    );

    try {
      debugPrint('[TestNotifier] 테스트 데이터 수정 시작: $id');

      final updatedTest = await _testRepository.updateTest(
        id: id,
        name: name,
        description: description,
      );

      // 현재 리스트에서 해당 테스트 업데이트
      final updatedTests = state.tests.map((test) {
        return test.id == id ? updatedTest : test;
      }).toList();

      state = state.copyWith(
        tests: updatedTests,
        selectedTest:
            state.selectedTest?.id == id ? updatedTest : state.selectedTest,
        isUpdating: false,
      );

      debugPrint('[TestNotifier] 테스트 데이터 수정 완료: ${updatedTest.name}');
      return true;
    } catch (e) {
      debugPrint('[TestNotifier] 테스트 데이터 수정 실패: $e');

      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 테스트 데이터 삭제
  Future<bool> deleteTest(String id) async {
    if (state.isDeleting) return false;

    state = state.copyWith(
      isDeleting: true,
      clearErrorMessage: true,
    );

    try {
      debugPrint('[TestNotifier] 테스트 데이터 삭제 시작: $id');

      final success = await _testRepository.deleteTest(id);

      if (success) {
        // 현재 리스트에서 해당 테스트 제거
        final updatedTests =
            state.tests.where((test) => test.id != id).toList();

        state = state.copyWith(
          tests: updatedTests,
          selectedTest:
              state.selectedTest?.id == id ? null : state.selectedTest,
          isDeleting: false,
          clearSelectedTest: state.selectedTest?.id == id,
        );

        debugPrint('[TestNotifier] 테스트 데이터 삭제 완료: $id');
        return true;
      } else {
        state = state.copyWith(
          isDeleting: false,
          errorMessage: '테스트 데이터 삭제에 실패했습니다.',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[TestNotifier] 테스트 데이터 삭제 실패: $e');

      state = state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 선택된 테스트 설정
  void setSelectedTest(TestModel? test) {
    state = state.copyWith(
      selectedTest: test,
      clearSelectedTest: test == null,
    );
    debugPrint('[TestNotifier] 선택된 테스트 설정: ${test?.id}');
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
    debugPrint('[TestNotifier] 에러 메시지 클리어');
  }

  /// 상태 초기화
  void reset() {
    state = const TestState();
    debugPrint('[TestNotifier] 상태 초기화');
  }
}

/// TestNotifier Provider
final testNotifierProvider =
    StateNotifierProvider<TestNotifier, TestState>((ref) {
  final testRepository = ref.watch(testRepositoryProvider);
  return TestNotifier(testRepository);
});

/// 편의를 위한 개별 Provider들
final testListProvider = Provider<List<TestModel>>((ref) {
  return ref.watch(testNotifierProvider).tests;
});

final selectedTestProvider = Provider<TestModel?>((ref) {
  return ref.watch(testNotifierProvider).selectedTest;
});

final testLoadingProvider = Provider<bool>((ref) {
  return ref.watch(testNotifierProvider).isLoading;
});

final testErrorProvider = Provider<String?>((ref) {
  return ref.watch(testNotifierProvider).errorMessage;
});

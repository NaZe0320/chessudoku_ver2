import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/domain/notifiers/test_notifier.dart';
import 'package:chessudoku/domain/states/test_state.dart';
import 'package:chessudoku/data/services/test_service.dart';
import 'package:chessudoku/data/repositories/test_repository_impl.dart';

void main() {
  group('Test Architecture Flow', () {
    late ProviderContainer container;
    late TestNotifier testNotifier;

    setUp(() {
      container = ProviderContainer();
      final testService = TestService();
      final testRepository = TestRepositoryImpl(testService);
      testNotifier = TestNotifier(testRepository);
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태 확인', () {
      expect(testNotifier.state.status, TestStatus.initial);
      expect(testNotifier.state.tests, isEmpty);
      expect(testNotifier.state.selectedTest, isNull);
      expect(testNotifier.state.errorMessage, isNull);
    });

    test('Mock 데이터 로드 테스트', () async {
      // When: 테스트 데이터 로드
      await testNotifier.loadTests();

      // Then: 상태 확인
      expect(testNotifier.state.status, TestStatus.success);
      expect(testNotifier.state.tests.length, 5); // Mock 데이터 5개
      expect(testNotifier.state.errorMessage, isNull);

      // Mock 데이터 내용 확인
      final firstTest = testNotifier.state.tests.first;
      expect(firstTest.id, '1');
      expect(firstTest.name, '첫 번째 테스트');
      expect(firstTest.description, '첫 번째 테스트 항목입니다.');
    });

    test('특정 ID로 테스트 데이터 조회', () async {
      // Given: 테스트 데이터 로드
      await testNotifier.loadTests();

      // When: 특정 ID로 조회
      await testNotifier.loadTestById('2');

      // Then: 선택된 테스트 확인
      expect(testNotifier.state.selectedTest, isNotNull);
      expect(testNotifier.state.selectedTest!.id, '2');
      expect(testNotifier.state.selectedTest!.name, '두 번째 테스트');
    });

    test('새로운 테스트 데이터 생성', () async {
      // Given: 기존 데이터 로드
      await testNotifier.loadTests();
      final initialCount = testNotifier.state.tests.length;

      // When: 새 테스트 생성
      final success = await testNotifier.createTest(
        name: '새로운 테스트',
        description: '새로 생성된 테스트입니다.',
      );

      // Then: 성공 확인 및 데이터 추가 확인
      expect(success, isTrue);
      expect(testNotifier.state.tests.length, initialCount + 1);
      expect(testNotifier.state.selectedTest, isNotNull);
      expect(testNotifier.state.selectedTest!.name, '새로운 테스트');
    });

    test('테스트 데이터 수정', () async {
      // Given: 기존 데이터 로드
      await testNotifier.loadTests();

      // When: 첫 번째 테스트 수정
      final success = await testNotifier.updateTest(
        id: '1',
        name: '수정된 테스트',
        description: '수정된 설명입니다.',
      );

      // Then: 성공 확인 및 데이터 변경 확인
      expect(success, isTrue);
      final updatedTest = testNotifier.state.getTestById('1');
      expect(updatedTest, isNotNull);
      expect(updatedTest!.name, '수정된 테스트');
      expect(updatedTest.description, '수정된 설명입니다.');
    });

    test('테스트 데이터 삭제', () async {
      // Given: 기존 데이터 로드
      await testNotifier.loadTests();
      final initialCount = testNotifier.state.tests.length;

      // When: 첫 번째 테스트 삭제
      final success = await testNotifier.deleteTest('1');

      // Then: 성공 확인 및 데이터 삭제 확인
      expect(success, isTrue);
      expect(testNotifier.state.tests.length, initialCount - 1);
      expect(testNotifier.state.getTestById('1'), isNull);
    });

    test('에러 상태 처리', () async {
      // When: 존재하지 않는 ID로 조회
      await testNotifier.loadTestById('999');

      // Then: 에러 메시지 확인
      expect(testNotifier.state.errorMessage, isNotNull);

      // When: 에러 클리어
      testNotifier.clearError();

      // Then: 에러 메시지 클리어 확인
      expect(testNotifier.state.errorMessage, isNull);
    });

    test('상태 초기화', () async {
      // Given: 데이터 로드 후 상태 변경
      await testNotifier.loadTests();
      await testNotifier.loadTestById('1');

      // When: 상태 초기화
      testNotifier.reset();

      // Then: 초기 상태로 복원 확인
      expect(testNotifier.state.status, TestStatus.initial);
      expect(testNotifier.state.tests, isEmpty);
      expect(testNotifier.state.selectedTest, isNull);
      expect(testNotifier.state.errorMessage, isNull);
    });

    test('Provider를 통한 데이터 접근', () async {
      // Given: Provider 컨테이너 설정
      final container = ProviderContainer();

      // When: Provider를 통해 데이터 로드
      final notifier = container.read(testNotifierProvider.notifier);
      await notifier.loadTests();

      // Then: Provider를 통한 데이터 접근 확인
      final tests = container.read(testListProvider);
      final isLoading = container.read(testLoadingProvider);
      final error = container.read(testErrorProvider);

      expect(tests.length, 5);
      expect(isLoading, isFalse);
      expect(error, isNull);

      container.dispose();
    });
  });

  group('TestService Mock 데이터 테스트', () {
    late TestService testService;

    setUp(() {
      testService = TestService();
    });

    test('getAllTests Mock 데이터 조회', () async {
      final tests = await testService.getAllTests();

      expect(tests, isNotEmpty);
      expect(tests.length, 5);
      expect(tests.first.name, '첫 번째 테스트');
    });

    test('getTestById Mock 데이터 조회', () async {
      final test = await testService.getTestById('3');

      expect(test, isNotNull);
      expect(test!.id, '3');
      expect(test.name, '세 번째 테스트');
    });

    test('createTest Mock 데이터 생성', () async {
      final newTest = await testService.createTest(
        name: '테스트 생성',
        description: '생성 테스트입니다.',
      );

      expect(newTest.name, '테스트 생성');
      expect(newTest.description, '생성 테스트입니다.');
      expect(newTest.id, isNotEmpty);
    });
  });
}

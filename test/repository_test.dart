import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/domain/notifiers/test_notifier.dart';
import 'package:chessudoku/domain/states/test_state.dart';
import 'package:chessudoku/data/services/test_service.dart';
import 'package:chessudoku/data/repositories/test_repository_impl.dart';
import 'package:chessudoku/domain/repositories/test_repository.dart';

void main() {
  group('Repository Architecture Flow', () {
    late ProviderContainer container;
    late TestNotifier testNotifier;
    late TestRepository testRepository;

    setUp(() {
      container = ProviderContainer();
      final testService = TestService();
      testRepository = TestRepositoryImpl(testService);
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

    test('Repository를 통한 Mock 데이터 로드 테스트', () async {
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

    test('Repository를 통한 특정 ID 데이터 조회', () async {
      // Given: 테스트 데이터 로드
      await testNotifier.loadTests();

      // When: 특정 ID로 조회
      await testNotifier.loadTestById('2');

      // Then: 선택된 테스트 확인
      expect(testNotifier.state.selectedTest, isNotNull);
      expect(testNotifier.state.selectedTest!.id, '2');
      expect(testNotifier.state.selectedTest!.name, '두 번째 테스트');
    });

    test('Repository를 통한 새로운 테스트 데이터 생성', () async {
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

    test('Repository를 통한 테스트 데이터 수정', () async {
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

    test('Repository를 통한 테스트 데이터 삭제', () async {
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

    test('Provider를 통한 의존성 주입 테스트', () async {
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

  group('Repository 레이어 직접 테스트', () {
    late TestRepository testRepository;

    setUp(() {
      final testService = TestService();
      testRepository = TestRepositoryImpl(testService);
    });

    test('Repository getAllTests 테스트', () async {
      final tests = await testRepository.getAllTests();

      expect(tests, isNotEmpty);
      expect(tests.length, 5);
      expect(tests.first.name, '첫 번째 테스트');
    });

    test('Repository getTestById 테스트', () async {
      final test = await testRepository.getTestById('3');

      expect(test, isNotNull);
      expect(test!.id, '3');
      expect(test.name, '세 번째 테스트');
    });

    test('Repository createTest 테스트', () async {
      final newTest = await testRepository.createTest(
        name: 'Repository 테스트',
        description: 'Repository를 통한 생성 테스트입니다.',
      );

      expect(newTest.name, 'Repository 테스트');
      expect(newTest.description, 'Repository를 통한 생성 테스트입니다.');
      expect(newTest.id, isNotEmpty);
    });

    test('Repository updateTest 테스트', () async {
      final updatedTest = await testRepository.updateTest(
        id: '1',
        name: 'Repository 수정',
        description: 'Repository를 통한 수정 테스트입니다.',
      );

      expect(updatedTest.id, '1');
      expect(updatedTest.name, 'Repository 수정');
      expect(updatedTest.description, 'Repository를 통한 수정 테스트입니다.');
    });

    test('Repository deleteTest 테스트', () async {
      final success = await testRepository.deleteTest('1');

      expect(success, isTrue);
    });

    test('Repository 존재하지 않는 데이터 조회 테스트', () async {
      final test = await testRepository.getTestById('999');

      expect(test, isNull);
    });
  });

  group('Service 레이어 테스트 (호환성 확인)', () {
    late TestService testService;

    setUp(() {
      testService = TestService();
    });

    test('Service getAllTests Mock 데이터 조회', () async {
      final tests = await testService.getAllTests();

      expect(tests, isNotEmpty);
      expect(tests.length, 5);
      expect(tests.first.name, '첫 번째 테스트');
    });

    test('Service createTest Mock 데이터 생성', () async {
      final newTest = await testService.createTest(
        name: 'Service 테스트',
        description: 'Service를 통한 생성 테스트입니다.',
      );

      expect(newTest.name, 'Service 테스트');
      expect(newTest.description, 'Service를 통한 생성 테스트입니다.');
      expect(newTest.id, isNotEmpty);
    });
  });

  group('아키텍처 레이어 분리 확인', () {
    test('의존성 방향 확인', () {
      // Given: 각 레이어 인스턴스 생성
      final testService = TestService();
      final testRepository = TestRepositoryImpl(testService);
      final testNotifier = TestNotifier(testRepository);

      // Then: 의존성 방향이 올바른지 확인
      // Domain -> Data 방향으로만 의존해야 함
      expect(testRepository, isA<TestRepository>());
      expect(testNotifier.state, isA<TestState>());

      // 초기 상태 확인
      expect(testNotifier.state.status, TestStatus.initial);
    });

    test('인터페이스 분리 확인', () {
      // Given: Repository 인터페이스
      final testService = TestService();
      final TestRepository repository = TestRepositoryImpl(testService);

      // Then: 추상화를 통한 접근 가능
      expect(repository, isA<TestRepository>());
      expect(repository, isA<TestRepositoryImpl>());
    });
  });
}

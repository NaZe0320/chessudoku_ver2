import 'package:flutter/foundation.dart';
import '../../domain/repositories/test_repository.dart';
import '../models/test_model.dart';
import '../services/test_service.dart';

/// TestRepository의 구체적인 구현체
/// TestService를 통해 실제 데이터 작업을 수행
class TestRepositoryImpl implements TestRepository {
  final TestService _testService;

  TestRepositoryImpl(this._testService);

  @override
  Future<List<TestModel>> getAllTests() async {
    try {
      debugPrint('[TestRepository] 모든 테스트 데이터 조회 요청');
      final result = await _testService.getAllTests();
      debugPrint('[TestRepository] 테스트 데이터 조회 완료: ${result.length}개');
      return result;
    } catch (e) {
      debugPrint('[TestRepository] 테스트 데이터 조회 실패: $e');
      rethrow;
    }
  }

  @override
  Future<TestModel?> getTestById(String id) async {
    try {
      debugPrint('[TestRepository] 테스트 데이터 조회 요청: $id');
      final result = await _testService.getTestById(id);
      debugPrint('[TestRepository] 테스트 데이터 조회 결과: ${result?.name ?? 'null'}');
      return result;
    } catch (e) {
      debugPrint('[TestRepository] 테스트 데이터 조회 실패: $e');
      rethrow;
    }
  }

  @override
  Future<TestModel> createTest({
    required String name,
    required String description,
  }) async {
    try {
      debugPrint('[TestRepository] 테스트 데이터 생성 요청: $name');
      final result = await _testService.createTest(
        name: name,
        description: description,
      );
      debugPrint('[TestRepository] 테스트 데이터 생성 완료: ${result.id}');
      return result;
    } catch (e) {
      debugPrint('[TestRepository] 테스트 데이터 생성 실패: $e');
      rethrow;
    }
  }

  @override
  Future<TestModel> updateTest({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      debugPrint('[TestRepository] 테스트 데이터 수정 요청: $id');
      final result = await _testService.updateTest(
        id: id,
        name: name,
        description: description,
      );
      debugPrint('[TestRepository] 테스트 데이터 수정 완료: ${result.name}');
      return result;
    } catch (e) {
      debugPrint('[TestRepository] 테스트 데이터 수정 실패: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteTest(String id) async {
    try {
      debugPrint('[TestRepository] 테스트 데이터 삭제 요청: $id');
      final result = await _testService.deleteTest(id);
      debugPrint('[TestRepository] 테스트 데이터 삭제 결과: $result');
      return result;
    } catch (e) {
      debugPrint('[TestRepository] 테스트 데이터 삭제 실패: $e');
      rethrow;
    }
  }
}

import '../../../data/models/test_model.dart';

/// 테스트 데이터 Repository 인터페이스
/// 데이터 소스를 추상화하여 도메인 레이어에서 사용
abstract class TestRepository {
  /// 모든 테스트 데이터 가져오기
  Future<List<TestModel>> getAllTests();

  /// 특정 ID의 테스트 데이터 가져오기
  Future<TestModel?> getTestById(String id);

  /// 새로운 테스트 데이터 생성
  Future<TestModel> createTest({
    required String name,
    required String description,
  });

  /// 테스트 데이터 수정
  Future<TestModel> updateTest({
    required String id,
    required String name,
    required String description,
  });

  /// 테스트 데이터 삭제
  Future<bool> deleteTest(String id);
}

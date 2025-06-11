import 'package:flutter/foundation.dart';
import '../models/test_model.dart';
import '../mock/test_mock_data.dart';

/// 테스트 데이터 관련 API 서비스
class TestService {

  /// 모든 테스트 데이터 가져오기
  Future<List<TestModel>> getAllTests() async {
    try {
      // Mock 모드일 때는 실제 API 호출 대신 Mock 데이터 사용
      if (kDebugMode) {
        debugPrint('[TestService] Mock 데이터 사용');
        // 실제 API 호출처럼 약간의 지연 시간 추가
        await Future.delayed(const Duration(milliseconds: 500));

        // Mock 데이터를 API 응답 형태로 가공
        final mockResponse = TestMockData.mockApiResponse;
        final List<dynamic> dataList = mockResponse['data'] as List<dynamic>;

        return dataList
            .map((json) => TestModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // 실제 API 호출 (현재는 주석 처리)
      /*
      final response = await _apiService.get<Map<String, dynamic>>('/tests');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data!['data'] as List<dynamic>;
        return dataList
            .map((json) => TestModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('테스트 데이터를 가져오는데 실패했습니다.');
      */

      // 현재는 Mock 데이터만 반환
      return TestMockData.testModelList;
    } catch (e) {
      debugPrint('[TestService] 에러 발생: $e');
      rethrow;
    }
  }

  /// 특정 ID의 테스트 데이터 가져오기
  Future<TestModel?> getTestById(String id) async {
    try {
      // Mock 모드일 때는 실제 API 호출 대신 Mock 데이터 사용
      if (kDebugMode) {
        debugPrint('[TestService] Mock 데이터에서 ID: $id 조회');
        await Future.delayed(const Duration(milliseconds: 300));

        return TestMockData.getTestModelById(id);
      }

      // 실제 API 호출 (현재는 주석 처리)
      /*
      final response = await _apiService.get<Map<String, dynamic>>('/tests/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>;
        return TestModel.fromJson(data);
      }
      
      return null;
      */

      // 현재는 Mock 데이터만 반환
      return TestMockData.getTestModelById(id);
    } catch (e) {
      debugPrint('[TestService] 에러 발생: $e');
      rethrow;
    }
  }

  /// 새로운 테스트 데이터 생성
  Future<TestModel> createTest({
    required String name,
    required String description,
  }) async {
    try {
      // Mock 모드일 때는 실제 API 호출 대신 Mock 데이터 사용
      if (kDebugMode) {
        debugPrint('[TestService] Mock 데이터로 새 테스트 생성');
        await Future.delayed(const Duration(milliseconds: 800));

        final newTestJson = TestMockData.createTestJson(
          name: name,
          description: description,
        );

        return TestModel.fromJson(newTestJson);
      }

      // 실제 API 호출 (현재는 주석 처리)
      /*
      final requestData = {
        'name': name,
        'description': description,
      };
      
      final response = await _apiService.post<Map<String, dynamic>>(
        '/tests',
        data: requestData,
      );
      
      if (response.statusCode == 201 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>;
        return TestModel.fromJson(data);
      }
      
      throw Exception('테스트 데이터 생성에 실패했습니다.');
      */

      // 현재는 Mock 데이터만 반환
      final newTestJson = TestMockData.createTestJson(
        name: name,
        description: description,
      );
      return TestModel.fromJson(newTestJson);
    } catch (e) {
      debugPrint('[TestService] 에러 발생: $e');
      rethrow;
    }
  }

  /// 테스트 데이터 수정
  Future<TestModel> updateTest({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      // Mock 모드일 때는 실제 API 호출 대신 Mock 데이터 사용
      if (kDebugMode) {
        debugPrint('[TestService] Mock 데이터로 테스트 수정: $id');
        await Future.delayed(const Duration(milliseconds: 600));

        final existingTest = TestMockData.getTestModelById(id);
        if (existingTest == null) {
          throw Exception('수정할 테스트 데이터를 찾을 수 없습니다.');
        }

        return existingTest.copyWith(
          name: name,
          description: description,
        );
      }

      // 실제 API 호출 (현재는 주석 처리)
      /*
      final requestData = {
        'name': name,
        'description': description,
      };
      
      final response = await _apiService.put<Map<String, dynamic>>(
        '/tests/$id',
        data: requestData,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>;
        return TestModel.fromJson(data);
      }
      
      throw Exception('테스트 데이터 수정에 실패했습니다.');
      */

      // 현재는 Mock 데이터만 반환
      final existingTest = TestMockData.getTestModelById(id);
      if (existingTest == null) {
        throw Exception('수정할 테스트 데이터를 찾을 수 없습니다.');
      }

      return existingTest.copyWith(
        name: name,
        description: description,
      );
    } catch (e) {
      debugPrint('[TestService] 에러 발생: $e');
      rethrow;
    }
  }

  /// 테스트 데이터 삭제
  Future<bool> deleteTest(String id) async {
    try {
      // Mock 모드일 때는 실제 API 호출 대신 Mock 데이터 사용
      if (kDebugMode) {
        debugPrint('[TestService] Mock 데이터에서 테스트 삭제: $id');
        await Future.delayed(const Duration(milliseconds: 400));

        final existingTest = TestMockData.getTestModelById(id);
        return existingTest != null;
      }

      // 실제 API 호출 (현재는 주석 처리)
      /*
      final response = await _apiService.delete('/tests/$id');
      
      return response.statusCode == 200;
      */

      // 현재는 Mock 데이터 확인만
      final existingTest = TestMockData.getTestModelById(id);
      return existingTest != null;
    } catch (e) {
      debugPrint('[TestService] 에러 발생: $e');
      rethrow;
    }
  }
}

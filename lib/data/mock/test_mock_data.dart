import '../models/test_model.dart';

/// 테스트용 Mock 데이터 클래스
class TestMockData {
  static final List<Map<String, dynamic>> testJsonList = [
    {
      'id': '1',
      'name': '첫 번째 테스트',
      'description': '첫 번째 테스트 항목입니다.',
      'created_at': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': '2',
      'name': '두 번째 테스트',
      'description': '두 번째 테스트 항목입니다.',
      'created_at': '2024-01-02T00:00:00.000Z',
    },
    {
      'id': '3',
      'name': '세 번째 테스트',
      'description': '세 번째 테스트 항목입니다.',
      'created_at': '2024-01-03T00:00:00.000Z',
    },
    {
      'id': '4',
      'name': '네 번째 테스트',
      'description': '네 번째 테스트 항목입니다.',
      'created_at': '2024-01-04T00:00:00.000Z',
    },
    {
      'id': '5',
      'name': '다섯 번째 테스트',
      'description': '다섯 번째 테스트 항목입니다.',
      'created_at': '2024-01-05T00:00:00.000Z',
    },
  ];

  /// Mock 데이터를 TestModel 리스트로 변환
  static List<TestModel> get testModelList {
    return testJsonList.map((json) => TestModel.fromJson(json)).toList();
  }

  /// 특정 ID의 Mock 데이터 가져오기
  static Map<String, dynamic>? getTestJsonById(String id) {
    try {
      return testJsonList.firstWhere((json) => json['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// 특정 ID의 TestModel 가져오기
  static TestModel? getTestModelById(String id) {
    final json = getTestJsonById(id);
    return json != null ? TestModel.fromJson(json) : null;
  }

  /// 새로운 테스트 데이터 생성용 JSON
  static Map<String, dynamic> createTestJson({
    required String name,
    required String description,
  }) {
    final now = DateTime.now();
    final newId = (testJsonList.length + 1).toString();

    return {
      'id': newId,
      'name': name,
      'description': description,
      'created_at': now.toIso8601String(),
    };
  }

  /// API 응답 형태의 Mock 데이터
  static Map<String, dynamic> get mockApiResponse {
    return {
      'success': true,
      'message': 'Mock 데이터 조회 성공',
      'data': testJsonList,
      'total': testJsonList.length,
    };
  }

  /// 단일 데이터 API 응답 형태
  static Map<String, dynamic> mockApiResponseById(String id) {
    final data = getTestJsonById(id);
    return {
      'success': data != null,
      'message': data != null ? 'Mock 데이터 조회 성공' : '데이터를 찾을 수 없습니다',
      'data': data,
    };
  }
}

import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// HTTP API 서비스
/// Node.js 서버와의 통신을 담당하는 싱글톤 클래스
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static Dio? _dio;

  // API 기본 설정
  static const String _baseUrl = 'http://localhost:3000/api';
  static const Duration _timeout = Duration(seconds: 30);

  // 싱글톤 패턴 적용
  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  /// Dio 인스턴스 가져오기
  Dio get dio {
    if (_dio != null) return _dio!;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 설정
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('API 요청: ${options.method} ${options.path}',
            name: 'ApiService');
        developer.log('요청 데이터: ${options.data}', name: 'ApiService');
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            'API 응답: ${response.statusCode} ${response.requestOptions.path}',
            name: 'ApiService');
        developer.log('응답 데이터: ${response.data}', name: 'ApiService');
        handler.next(response);
      },
      onError: (error, handler) {
        developer.log('API 오류: ${error.message}', name: 'ApiService');
        developer.log('오류 상세: ${error.response?.data}', name: 'ApiService');
        handler.next(error);
      },
    ));

    return _dio!;
  }

  // ==================== HTTP 메서드 ====================

  /// GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      developer.log('GET 요청: $path', name: 'ApiService');
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      developer.log('GET 요청 실패: $path - ${e.message}', name: 'ApiService');
      throw _handleDioError(e, 'GET 요청');
    }
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data}) async {
    try {
      developer.log('POST 요청: $path', name: 'ApiService');
      final response = await dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      developer.log('POST 요청 실패: $path - ${e.message}', name: 'ApiService');
      throw _handleDioError(e, 'POST 요청');
    }
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    try {
      developer.log('PUT 요청: $path', name: 'ApiService');
      final response = await dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      developer.log('PUT 요청 실패: $path - ${e.message}', name: 'ApiService');
      throw _handleDioError(e, 'PUT 요청');
    }
  }

  /// DELETE 요청
  Future<Response> delete(String path) async {
    try {
      developer.log('DELETE 요청: $path', name: 'ApiService');
      final response = await dio.delete(path);
      return response;
    } on DioException catch (e) {
      developer.log('DELETE 요청 실패: $path - ${e.message}', name: 'ApiService');
      throw _handleDioError(e, 'DELETE 요청');
    }
  }

  // ==================== 유틸리티 메서드 ====================

  /// DioException을 ApiException으로 변환
  ApiException _handleDioError(DioException e, String operation) {
    String message;
    int? statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = '$operation: 연결 시간 초과';
        break;
      case DioExceptionType.sendTimeout:
        message = '$operation: 전송 시간 초과';
        break;
      case DioExceptionType.receiveTimeout:
        message = '$operation: 수신 시간 초과';
        break;
      case DioExceptionType.badResponse:
        statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'] as String;
        } else {
          message = '$operation: 서버 오류 (${e.response?.statusCode})';
        }
        break;
      case DioExceptionType.cancel:
        message = '$operation: 요청이 취소되었습니다';
        break;
      case DioExceptionType.connectionError:
        message = '$operation: 네트워크 연결 오류';
        break;
      default:
        message = '$operation: 네트워크 오류가 발생했습니다';
    }

    return ApiException(message, statusCode);
  }

  /// 리소스 정리
  void dispose() {
    _dio?.close();
    _dio = null;
  }
}

/// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

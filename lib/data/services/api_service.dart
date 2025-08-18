import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_error_handler.dart';
import '../interceptors/api_interceptor.dart';

/// HTTP API 서비스
/// Node.js 서버와의 통신을 담당하는 클래스
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      headers: ApiConfig.defaultHeaders,
    ));

    _dio.interceptors.add(ApiInterceptor());
  }

  // ==================== HTTP 메서드 ====================

  /// GET 요청
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e, 'GET 요청');
    }
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e, 'POST 요청');
    }
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e, 'PUT 요청');
    }
  }

  /// DELETE 요청
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e, 'DELETE 요청');
    }
  }

  /// 리소스 정리
  void dispose() {
    _dio.close();
  }
}

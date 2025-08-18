import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// API 인터셉터 클래스
/// 요청/응답/에러에 대한 로깅을 담당
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    developer.log('API 요청: ${options.method} ${options.path}',
        name: 'ApiInterceptor');
    if (options.data != null) {
      developer.log('요청 데이터: ${options.data}', name: 'ApiInterceptor');
    }
  }

  void _logResponse(Response response) {
    developer.log(
        'API 응답: ${response.statusCode} ${response.requestOptions.path}',
        name: 'ApiInterceptor');
    developer.log('응답 데이터: ${response.data}', name: 'ApiInterceptor');
  }

  void _logError(DioException error) {
    developer.log('API 오류: ${error.message}', name: 'ApiInterceptor');
    if (error.response?.data != null) {
      developer.log('오류 상세: ${error.response?.data}', name: 'ApiInterceptor');
    }
  }
}

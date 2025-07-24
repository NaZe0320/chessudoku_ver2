import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용할 수 있는 API 서비스
/// HTTP 통신을 담당하는 싱글톤 클래스
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static Dio? _dio;

  // 기본 설정
  static const String _baseUrl =
      'https://api.example.com'; // TODO: 실제 API URL로 변경
  static const int _connectTimeout = 30000; // 30초
  static const int _receiveTimeout = 30000; // 30초
  static const int _sendTimeout = 30000; // 30초

  // 싱글톤 패턴 적용
  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  /// Dio 인스턴스 가져오기
  Dio get dio {
    if (_dio != null) return _dio!;
    _dio = _initDio();
    return _dio!;
  }

  /// Dio 클라이언트 초기화
  Dio _initDio() {
    debugPrint('API 서비스 초기화: $_baseUrl');

    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: _connectTimeout),
      receiveTimeout: const Duration(milliseconds: _receiveTimeout),
      sendTimeout: const Duration(milliseconds: _sendTimeout),
      responseType: ResponseType.json,
      contentType: 'application/json',
    ));

    // 인터셉터 추가
    dio.interceptors.add(_createInterceptor());

    // 디버그 모드에서 로깅 인터셉터 추가
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ));
    }

    return dio;
  }

  /// 커스텀 인터셉터 생성
  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 요청 전 처리 (토큰 추가 등)
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        debugPrint('[API 요청] ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
            '[API 응답] ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
            '[API 오류] ${error.response?.statusCode} ${error.requestOptions.path}');
        debugPrint('[API 오류 메시지] ${error.message}');
        handler.next(error);
      },
    );
  }

  /// 인증 토큰 가져오기 (SharedPreferences 등에서)
  Future<String?> _getAuthToken() async {
    // TODO: SharedPreferences나 다른 저장소에서 토큰 가져오기
    return null;
  }

  /// GET 요청
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 요청
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 요청
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 요청
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 요청
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 파일 다운로드
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      final response = await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 에러 처리
  Exception _handleError(DioException error) {
    String message = '네트워크 오류가 발생했습니다.';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = '연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.sendTimeout:
        message = '요청 전송 시간이 초과되었습니다.';
        break;
      case DioExceptionType.receiveTimeout:
        message = '응답 수신 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            message = '잘못된 요청입니다.';
            break;
          case 401:
            message = '인증이 필요합니다.';
            break;
          case 403:
            message = '접근 권한이 없습니다.';
            break;
          case 404:
            message = '요청한 리소스를 찾을 수 없습니다.';
            break;
          case 500:
            message = '서버 내부 오류가 발생했습니다.';
            break;
          default:
            message = '서버 오류가 발생했습니다. (${statusCode ?? 'unknown'})';
        }
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다.';
        break;
      case DioExceptionType.unknown:
        message = '알 수 없는 오류가 발생했습니다.';
        break;
      default:
        message = '네트워크 오류가 발생했습니다.';
    }

    debugPrint('[API 오류 처리] $message');
    debugPrint('[API 오류 상세] ${error.toString()}');

    return ApiException(message, error.response?.statusCode);
  }

  /// 베이스 URL 업데이트
  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
    debugPrint('API 베이스 URL 업데이트: $newBaseUrl');
  }

  /// 헤더 추가/업데이트
  void updateHeaders(Map<String, String> headers) {
    dio.options.headers.addAll(headers);
    debugPrint('API 헤더 업데이트: $headers');
  }

  /// 인증 토큰 설정
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('API 인증 토큰 설정 완료');
  }

  /// 인증 토큰 제거
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
    debugPrint('API 인증 토큰 제거 완료');
  }

  /// 클라이언트 종료
  void close() {
    _dio?.close();
    _dio = null;
    debugPrint('API 서비스 종료');
  }
}

/// 커스텀 API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Code: $statusCode)' : ''}';
}

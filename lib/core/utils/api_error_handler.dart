import 'package:dio/dio.dart';

/// API 에러 처리 유틸리티 클래스
class ApiErrorHandler {
  static ApiException handleDioError(DioException e, String operation) {
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
        message = _extractErrorMessage(e.response?.data, operation, statusCode);
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

  static String _extractErrorMessage(
      dynamic responseData, String operation, int? statusCode) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      return responseData['message'] as String;
    }
    return '$operation: 서버 오류 (${statusCode ?? '알 수 없음'})';
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

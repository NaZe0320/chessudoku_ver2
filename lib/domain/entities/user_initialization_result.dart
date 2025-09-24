import 'package:chessudoku/domain/entities/user.dart';

/// 사용자 초기화 결과
class UserInitializationResult {
  final User? user;
  final UserInitializationStatus status;
  final String? errorMessage;

  const UserInitializationResult({
    this.user,
    required this.status,
    this.errorMessage,
  });

  /// 성공
  UserInitializationResult.success(User user)
      : user = user,
        status = UserInitializationStatus.success,
        errorMessage = null;

  /// 네트워크 오류 (오프라인)
  UserInitializationResult.networkError([String? message])
      : user = null,
        status = UserInitializationStatus.networkError,
        errorMessage = message ?? '네트워크 연결을 확인해주세요';

  /// 서버 오류 (4xx, 5xx 등)
  UserInitializationResult.serverError([String? message])
      : user = null,
        status = UserInitializationStatus.serverError,
        errorMessage = message ?? '서버에 문제가 발생했습니다';

  /// 기타 오류
  UserInitializationResult.unknownError([String? message])
      : user = null,
        status = UserInitializationStatus.unknownError,
        errorMessage = message ?? '알 수 없는 오류가 발생했습니다';

  bool get isSuccess => status == UserInitializationStatus.success;
  bool get isNetworkError => status == UserInitializationStatus.networkError;
  bool get isServerError => status == UserInitializationStatus.serverError;
  bool get isUnknownError => status == UserInitializationStatus.unknownError;
}

enum UserInitializationStatus {
  success,
  networkError,
  serverError,
  unknownError,
}

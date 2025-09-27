import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// 사용자 데이터 모델
@freezed
class User with _$User {
  const factory User({
    required String userId,
    required String deviceId,
    required String nickname,
    required DateTime createAt,
  }) = _User;

  const User._();

  /// 서버 응답 JSON에서 User 객체 생성 (Freezed fromJson 오버라이드)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      nickname: json['nickname'] as String,
      createAt: DateTime.parse(json['create_at'] as String),
    );
  }

  /// 서버 전송용 JSON 변환 (Freezed toJson 오버라이드)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'device_id': deviceId,
      'nickname': nickname,
      'create_at': createAt.toIso8601String(),
    };
  }

  /// 서버 응답에서 User 생성 (data 필드 추출)
  factory User.fromServerResponse(Map<String, dynamic> response) {
    final userData = response['data'] as Map<String, dynamic>;
    return User.fromJson(userData);
  }
}

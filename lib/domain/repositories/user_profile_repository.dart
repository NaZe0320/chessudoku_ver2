import 'package:chessudoku/data/models/user_profile.dart';

/// 사용자 프로필 관리를 위한 Repository 인터페이스
abstract class UserProfileRepository {
  /// 현재 사용자 프로필 조회
  Future<UserProfile?> getUserProfile();

  /// 사용자 프로필 생성
  Future<UserProfile> createUserProfile(UserProfile profile);

  /// 사용자 프로필 업데이트
  Future<UserProfile> updateUserProfile(UserProfile profile);

  /// 마지막 로그인 시간 업데이트
  Future<void> updateLastLogin();
}

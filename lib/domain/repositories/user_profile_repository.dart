import 'package:chessudoku/domain/entities/user_profile.dart';

/// 사용자 프로필 관리를 위한 Repository 인터페이스
abstract class UserProfileRepository {
  /// 현재 사용자 프로필 조회
  Future<UserProfile?> getUserProfile();
}

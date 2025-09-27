import 'package:chessudoku/domain/entities/user.dart';

/// 사용자 관리를 위한 Repository 인터페이스
abstract class UserRepository {
  /// 디바이스 ID로 사용자 조회 + 자동 등록
  /// 사용자가 없으면 자동으로 새 사용자 생성
  Future<User?> getUserByDeviceId(String deviceId);

  /// 사용자 ID로 사용자 조회
  /// 사용자가 없으면 null 반환
  Future<User?> getUserById(String userId);

  /// 사용자 탈퇴
  Future<bool> withdrawUser(String userId);
}

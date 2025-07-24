import 'package:chessudoku/data/models/user_account.dart';
import 'package:chessudoku/data/models/game_history.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

abstract class UserAccountRepository {
  /// 디바이스 ID로 사용자 프로필 생성 또는 업데이트
  Future<UserProfile> createOrUpdateProfile(String deviceId);
  
  /// 디바이스 ID로 사용자 프로필 조회
  Future<UserProfile?> getProfile(String deviceId);
  
  /// 퍼즐 완료 시 통계 업데이트
  Future<void> updatePuzzleCompletion(String deviceId, String puzzleId, Difficulty difficulty, int playTimeSeconds);
  
  /// 게임 히스토리 추가
  Future<void> addGameHistory(String puzzleId, Difficulty difficulty, int playTimeSeconds, bool isCompleted);
  
  /// 완료한 퍼즐 수 조회
  Future<int> getCompletedPuzzlesCount(String deviceId);
  
  /// 현재 연속 기록 조회
  Future<int> getCurrentStreak(String deviceId);
  
  /// 총 플레이 시간 조회
  Future<int> getTotalPlayTime(String deviceId);
}

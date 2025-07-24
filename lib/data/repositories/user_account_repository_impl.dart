import 'package:chessudoku/data/models/user_account.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/domain/repositories/user_account_repository.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:flutter/foundation.dart';

class UserAccountRepositoryImpl implements UserAccountRepository {
  final DatabaseService _databaseService;

  UserAccountRepositoryImpl(this._databaseService);

  @override
  Future<UserProfile> createOrUpdateProfile(String deviceId) async {
    try {
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;

      // 기존 프로필 확인
      final existingProfile = await getProfile(deviceId);

      if (existingProfile != null) {
        return existingProfile;
      } else {
        // 새 프로필 생성
        await _databaseService.insert(
          DatabaseService.tableUserProfiles,
          {
            'deviceId': deviceId,
            'completedPuzzles': 0,
            'currentStreak': 0,
            'longestStreak': 0,
            'totalPlayTime': 0,
            'lastCompletedDate': null,
          },
        );

        return UserProfile(
          deviceId: deviceId,
          completedPuzzles: 0,
          currentStreak: 0,
          longestStreak: 0,
          totalPlayTime: 0,
          lastCompletedDate: null,
        );
      }
    } catch (e) {
      debugPrint('[UserAccountRepository] 프로필 생성/업데이트 실패: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile?> getProfile(String deviceId) async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tableUserProfiles,
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );

      if (result.isNotEmpty) {
        final data = result.first;
        return UserProfile(
          deviceId: data['deviceId'] as String,
          completedPuzzles: data['completedPuzzles'] as int,
          currentStreak: data['currentStreak'] as int,
          longestStreak: data['longestStreak'] as int,
          totalPlayTime: data['totalPlayTime'] as int,
          lastCompletedDate: data['lastCompletedDate'] != null
              ? DateTime.parse(data['lastCompletedDate'] as String)
              : null,
        );
      }
      return null;
    } catch (e) {
      debugPrint('[UserAccountRepository] 프로필 조회 실패: $e');
      return null;
    }
  }

  @override
  Future<void> updatePuzzleCompletion(String deviceId, String puzzleId,
      Difficulty difficulty, int playTimeSeconds) async {
    try {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0];

      // 현재 프로필 조회
      final currentProfile = await getProfile(deviceId);
      if (currentProfile == null) {
        await createOrUpdateProfile(deviceId);
      }

      // 게임 히스토리 추가
      await addGameHistory(puzzleId, difficulty, playTimeSeconds, true);

      // 프로필 통계 업데이트
      final updatedProfile = await _calculateUpdatedProfile(deviceId, today);

      await _databaseService.update(
        DatabaseService.tableUserProfiles,
        {
          'completedPuzzles': updatedProfile.completedPuzzles,
          'currentStreak': updatedProfile.currentStreak,
          'longestStreak': updatedProfile.longestStreak,
          'totalPlayTime': updatedProfile.totalPlayTime,
          'lastCompletedDate':
              updatedProfile.lastCompletedDate?.toIso8601String().split('T')[0],
        },
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );

      debugPrint('[UserAccountRepository] 퍼즐 완료 통계 업데이트: $deviceId');
    } catch (e) {
      debugPrint('[UserAccountRepository] 퍼즐 완료 통계 업데이트 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> addGameHistory(String puzzleId, Difficulty difficulty,
      int playTimeSeconds, bool isCompleted) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _databaseService.insert(
        DatabaseService.tableGameHistory,
        {
          'puzzleId': puzzleId,
          'difficulty': difficulty.name,
          'completedAt': timestamp,
          'playTimeSeconds': playTimeSeconds,
          'isCompleted': isCompleted ? 1 : 0,
        },
      );
    } catch (e) {
      debugPrint('[UserAccountRepository] 게임 히스토리 추가 실패: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCompletedPuzzlesCount(String deviceId) async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tableGameHistory,
        columns: ['COUNT(*) as count'],
        where: 'isCompleted = ?',
        whereArgs: [1],
      );

      if (result.isNotEmpty) {
        return result.first['count'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint('[UserAccountRepository] 완료한 퍼즐 수 조회 실패: $e');
      return 0;
    }
  }

  @override
  Future<int> getCurrentStreak(String deviceId) async {
    try {
      final profile = await getProfile(deviceId);
      return profile?.currentStreak ?? 0;
    } catch (e) {
      debugPrint('[UserAccountRepository] 현재 연속 기록 조회 실패: $e');
      return 0;
    }
  }

  @override
  Future<int> getTotalPlayTime(String deviceId) async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tableGameHistory,
        columns: ['SUM(playTimeSeconds) as total'],
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return result.first['total'] as int;
      }
      return 0;
    } catch (e) {
      debugPrint('[UserAccountRepository] 총 플레이 시간 조회 실패: $e');
      return 0;
    }
  }

  /// 업데이트된 프로필 계산
  Future<UserProfile> _calculateUpdatedProfile(
      String deviceId, String today) async {
    final currentProfile =
        await getProfile(deviceId) ?? UserProfile(deviceId: deviceId);

    // 완료한 퍼즐 수
    final completedPuzzles = await getCompletedPuzzlesCount(deviceId);

    // 총 플레이 시간
    final totalPlayTime = await getTotalPlayTime(deviceId);

    // 연속 기록 계산
    int newCurrentStreak = currentProfile.currentStreak;
    int newLongestStreak = currentProfile.longestStreak;

    if (currentProfile.lastCompletedDate != null) {
      final lastDate = currentProfile.lastCompletedDate!;
      final lastDateStr = lastDate.toIso8601String().split('T')[0];

      if (today == lastDateStr) {
        // 오늘 이미 완료했으면 연속 기록 증가하지 않음
      } else if (_isConsecutiveDay(lastDateStr, today)) {
        // 연속된 날짜면 연속 기록 증가
        newCurrentStreak++;
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
        }
      } else {
        // 연속이 끊어지면 1로 리셋
        newCurrentStreak = 1;
      }
    } else {
      // 첫 번째 완료
      newCurrentStreak = 1;
      newLongestStreak = 1;
    }

    return currentProfile.copyWith(
      completedPuzzles: completedPuzzles,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      totalPlayTime: totalPlayTime,
      lastCompletedDate: DateTime.parse(today),
    );
  }

  /// 연속된 날짜인지 확인하는 헬퍼 메서드
  bool _isConsecutiveDay(String lastDate, String today) {
    try {
      final last = DateTime.parse(lastDate);
      final current = DateTime.parse(today);
      final difference = current.difference(last).inDays;
      return difference == 1;
    } catch (e) {
      debugPrint('[UserAccountRepository] 날짜 비교 실패: $e');
      return false;
    }
  }
}

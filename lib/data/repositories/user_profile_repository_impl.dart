import 'dart:developer' as developer;
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/device_service.dart';
import 'package:chessudoku/domain/repositories/user_profile_repository.dart';
import 'package:chessudoku/data/models/user_profile.dart';

/// 사용자 프로필 Repository 구현체
class UserProfileRepositoryImpl implements UserProfileRepository {
  final DatabaseService _databaseService;
  final DeviceService _deviceService;

  UserProfileRepositoryImpl(this._databaseService, this._deviceService);

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final result = await _databaseService.query(
        DatabaseService.tableUserProfiles,
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );

      if (result.isNotEmpty) {
        final data = result.first;
        return UserProfile(
          deviceId: data['deviceId'] as String,
          username: data['username'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          lastLoginAt: DateTime.parse(data['lastLoginAt'] as String),
          totalPlayTime: data['totalPlayTime'] as int,
          completedPuzzles: data['completedPuzzles'] as int,
          currentStreak: data['currentStreak'] as int,
          bestStreak: data['bestStreak'] as int,
        );
      }
      return null;
    } catch (e) {
      developer.log('사용자 프로필 조회 실패: $e', name: 'UserProfileRepository');
      return null;
    }
  }

  @override
  Future<UserProfile> createUserProfile(UserProfile profile) async {
    try {
      await _databaseService.insert(
        DatabaseService.tableUserProfiles,
        {
          'deviceId': profile.deviceId,
          'username': profile.username,
          'createdAt': profile.createdAt.toIso8601String(),
          'lastLoginAt': profile.lastLoginAt.toIso8601String(),
          'totalPlayTime': profile.totalPlayTime,
          'completedPuzzles': profile.completedPuzzles,
          'currentStreak': profile.currentStreak,
          'bestStreak': profile.bestStreak,
        },
      );
      developer.log('사용자 프로필 생성 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');
      return profile;
    } catch (e) {
      developer.log('사용자 프로필 생성 실패: $e', name: 'UserProfileRepository');
      rethrow;
    }
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    try {
      await _databaseService.update(
        DatabaseService.tableUserProfiles,
        {
          'username': profile.username,
          'lastLoginAt': profile.lastLoginAt.toIso8601String(),
          'totalPlayTime': profile.totalPlayTime,
          'completedPuzzles': profile.completedPuzzles,
          'currentStreak': profile.currentStreak,
          'bestStreak': profile.bestStreak,
        },
        where: 'deviceId = ?',
        whereArgs: [profile.deviceId],
      );
      developer.log('사용자 프로필 업데이트 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');
      return profile;
    } catch (e) {
      developer.log('사용자 프로필 업데이트 실패: $e', name: 'UserProfileRepository');
      rethrow;
    }
  }

  @override
  Future<void> updateLastLogin() async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      await _databaseService.update(
        DatabaseService.tableUserProfiles,
        {
          'lastLoginAt': DateTime.now().toIso8601String(),
        },
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );
    } catch (e) {
      developer.log('마지막 로그인 시간 업데이트 실패: $e', name: 'UserProfileRepository');
    }
  }

  @override
  Future<void> incrementCompletedPuzzles() async {
    try {
      developer.log('완료한 퍼즐 수 증가 시작', name: 'UserProfileRepository');
      final deviceId = await _deviceService.getDeviceId();
      developer.log('DeviceId: $deviceId', name: 'UserProfileRepository');

      final currentProfile = await getUserProfile();
      developer.log('현재 프로필: ${currentProfile?.completedPuzzles}개 완료',
          name: 'UserProfileRepository');

      if (currentProfile != null) {
        final newCompletedPuzzles = currentProfile.completedPuzzles + 1;
        developer.log('새 완료 퍼즐 수: $newCompletedPuzzles',
            name: 'UserProfileRepository');

        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'completedPuzzles': newCompletedPuzzles,
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );
        developer.log('완료한 퍼즐 수 업데이트 완료', name: 'UserProfileRepository');
      } else {
        developer.log('사용자 프로필이 없습니다', name: 'UserProfileRepository');
      }
    } catch (e) {
      developer.log('완료한 퍼즐 수 증가 실패: $e', name: 'UserProfileRepository');
    }
  }

  @override
  Future<void> updateStreak(int newStreak) async {
    try {
      developer.log('연속 기록 업데이트 시작: $newStreak', name: 'UserProfileRepository');
      final deviceId = await _deviceService.getDeviceId();
      final currentProfile = await getUserProfile();
      if (currentProfile != null) {
        final bestStreak = newStreak > currentProfile.bestStreak
            ? newStreak
            : currentProfile.bestStreak;
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'currentStreak': newStreak,
            'bestStreak': bestStreak,
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );
        developer.log(
            '연속 기록 업데이트 완료: currentStreak=$newStreak, bestStreak=$bestStreak',
            name: 'UserProfileRepository');
      }
    } catch (e) {
      developer.log('연속 기록 업데이트 실패: $e', name: 'UserProfileRepository');
    }
  }

  @override
  Future<void> updateStreakOnGameCompletion() async {
    try {
      developer.log('게임 완료 시 연속 기록 계산 시작', name: 'UserProfileRepository');
      final deviceId = await _deviceService.getDeviceId();
      final currentProfile = await getUserProfile();

      if (currentProfile != null) {
        final today = DateTime.now();
        final lastLoginDate = currentProfile.lastLoginAt;

        // 오늘 날짜와 마지막 로그인 날짜 비교
        final isToday = today.year == lastLoginDate.year &&
            today.month == lastLoginDate.month &&
            today.day == lastLoginDate.day;

        developer.log('오늘 날짜: ${today.toIso8601String()}',
            name: 'UserProfileRepository');
        developer.log('마지막 로그인: ${lastLoginDate.toIso8601String()}',
            name: 'UserProfileRepository');
        developer.log('오늘 로그인 여부: $isToday', name: 'UserProfileRepository');

        int newStreak;
        if (isToday) {
          // 오늘 이미 로그인했다면 연속 기록 유지
          newStreak = currentProfile.currentStreak;
          developer.log('오늘 이미 로그인함 - 연속 기록 유지: $newStreak',
              name: 'UserProfileRepository');
        } else {
          // 어제 로그인했다면 연속 기록 증가
          final yesterday = today.subtract(const Duration(days: 1));
          final isYesterday = yesterday.year == lastLoginDate.year &&
              yesterday.month == lastLoginDate.month &&
              yesterday.day == lastLoginDate.day;

          if (isYesterday) {
            newStreak = currentProfile.currentStreak + 1;
            developer.log('어제 로그인함 - 연속 기록 증가: $newStreak',
                name: 'UserProfileRepository');
          } else {
            // 연속이 끊어졌으므로 1로 리셋
            newStreak = 1;
            developer.log('연속 기록 끊어짐 - 1로 리셋', name: 'UserProfileRepository');
          }
        }

        // 최고 기록 업데이트
        final bestStreak = newStreak > currentProfile.bestStreak
            ? newStreak
            : currentProfile.bestStreak;

        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'currentStreak': newStreak,
            'bestStreak': bestStreak,
            'lastLoginAt': today.toIso8601String(),
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );

        developer.log(
            '연속 기록 업데이트 완료: currentStreak=$newStreak, bestStreak=$bestStreak',
            name: 'UserProfileRepository');
      }
    } catch (e) {
      developer.log('게임 완료 시 연속 기록 계산 실패: $e', name: 'UserProfileRepository');
    }
  }

  @override
  Future<void> updatePlayTime(int additionalSeconds) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final currentProfile = await getUserProfile();
      if (currentProfile != null) {
        final newTotalPlayTime =
            currentProfile.totalPlayTime + additionalSeconds;
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'totalPlayTime': newTotalPlayTime,
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );
      }
    } catch (e) {
      developer.log('플레이 시간 업데이트 실패: $e', name: 'UserProfileRepository');
    }
  }
}

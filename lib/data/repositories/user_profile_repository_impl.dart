import 'dart:developer' as developer;
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/device_service.dart';
import 'package:chessudoku/domain/repositories/user_profile_repository.dart';
import 'package:chessudoku/data/models/user_profile.dart';
import 'package:chessudoku/core/sync/sync_manager.dart';
import 'package:chessudoku/core/sync/sync_strategy.dart';
import 'package:chessudoku/core/network/network_service.dart';

/// 사용자 프로필 Repository 구현체
class UserProfileRepositoryImpl implements UserProfileRepository {
  final DatabaseService _databaseService;
  final DeviceService _deviceService;
  final NetworkService _networkService;
  final SyncManager _syncManager;

  UserProfileRepositoryImpl(this._databaseService, this._deviceService,
      this._networkService, this._syncManager);

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
        // 로컬에 프로필이 있는 경우
        final data = result.first;
        final localProfile = UserProfile(
          deviceId: data['deviceId'] as String,
          username: data['username'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          lastLoginAt: DateTime.parse(data['lastLoginAt'] as String),
          totalPlayTime: data['totalPlayTime'] as int,
          completedPuzzles: data['completedPuzzles'] as int,
          currentStreak: data['currentStreak'] as int,
          bestStreak: data['bestStreak'] as int,
        );

        // 서버에서 데이터 가져와서 병합 (온라인인 경우만)
        if (_networkService.isOnline) {
          final mergedProfile = await _mergeWithServerData(localProfile);
          return mergedProfile;
        }

        return localProfile;
      } else {
        // 로컬에 프로필이 없는 경우
        developer.log('로컬에 프로필 없음, 서버에서 확인: $deviceId',
            name: 'UserProfileRepository');

        UserProfile? finalProfile;

        // 온라인 상태에서는 서버에서 기존 프로필 확인
        if (_networkService.isOnline) {
          final serverProfile = await _getServerProfile(deviceId);
          if (serverProfile != null) {
            developer.log('서버에서 기존 프로필 발견, 로컬에 저장',
                name: 'UserProfileRepository');
            // 서버 데이터를 로컬에 저장
            await _saveProfileToLocal(serverProfile);
            finalProfile = serverProfile;
          }
        }

        // 서버에도 없으면 새 프로필 생성
        if (finalProfile == null) {
          developer.log('서버에도 프로필 없음, 새 프로필 생성: $deviceId',
              name: 'UserProfileRepository');

          final newProfile = UserProfile(
            deviceId: deviceId,
            username: 'Player',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            totalPlayTime: 0,
            completedPuzzles: 0,
            currentStreak: 0,
            bestStreak: 0,
          );

          // 로컬에 저장
          await _saveProfileToLocal(newProfile);

          // 서버에 백업 (배치 동기화로 처리)
          await _queueProfileForSync(newProfile);

          developer.log('새 프로필 생성 완료', name: 'UserProfileRepository');
          finalProfile = newProfile;
        }

        return finalProfile;
      }
    } catch (e) {
      developer.log('사용자 프로필 조회 실패: $e', name: 'UserProfileRepository');
      return null;
    }
  }

  @override
  Future<UserProfile> createUserProfile(UserProfile profile) async {
    try {
      // 로컬 버전 초기화
      const initialVersion = 1;

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
          'serverVersion': initialVersion,
          'isDirty': 1, // 서버 동기화 필요
        },
      );
      developer.log('사용자 프로필 생성 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');

      // 배치 동기화로 처리
      await _queueProfileForSync(profile);

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
          'isDirty': 1, // 서버 동기화 필요
        },
        where: 'deviceId = ?',
        whereArgs: [profile.deviceId],
      );
      developer.log('사용자 프로필 업데이트 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');

      // 배치 동기화로 처리
      await _queueProfileForSync(profile);

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
      // lastLoginAt은 자주 변경되므로 즉시 동기화하지 않음
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

        // 로컬 업데이트
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'completedPuzzles': newCompletedPuzzles,
            'isDirty': 1, // 서버 동기화 필요
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );
        developer.log('완료한 퍼즐 수 로컬 업데이트 완료', name: 'UserProfileRepository');

        // 배치 동기화로 처리
        final updatedProfile =
            currentProfile.copyWith(completedPuzzles: newCompletedPuzzles);
        await _queueProfileForSync(updatedProfile);

        developer.log('완료한 퍼즐 수 동기화 큐에 추가', name: 'UserProfileRepository');
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
            'isDirty': 1, // 서버 동기화 필요
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );
        developer.log(
            '연속 기록 업데이트 완료: currentStreak=$newStreak, bestStreak=$bestStreak',
            name: 'UserProfileRepository');

        // 배치 동기화로 처리
        final updatedProfile = currentProfile.copyWith(
          currentStreak: newStreak,
          bestStreak: bestStreak,
        );
        await _queueProfileForSync(updatedProfile);

        developer.log('연속 기록 동기화 큐에 추가', name: 'UserProfileRepository');
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

        // 로컬 업데이트
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'currentStreak': newStreak,
            'bestStreak': bestStreak,
            'isDirty': 1, // 서버 동기화 필요
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );

        developer.log(
            '연속 기록 로컬 업데이트 완료: currentStreak=$newStreak, bestStreak=$bestStreak',
            name: 'UserProfileRepository');

        // 배치 동기화로 처리
        final updatedProfile = currentProfile.copyWith(
          currentStreak: newStreak,
          bestStreak: bestStreak,
        );
        await _queueProfileForSync(updatedProfile);
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

        // 로컬 업데이트
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'totalPlayTime': newTotalPlayTime,
            'isDirty': 1, // 서버 동기화 필요 표시
          },
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );

        // 배치 동기화로 처리
        final updatedProfile =
            currentProfile.copyWith(totalPlayTime: newTotalPlayTime);
        await _queueProfileForSync(updatedProfile);
      }
    } catch (e) {
      developer.log('플레이 시간 업데이트 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 서버에서 프로필 데이터 가져오기
  Future<UserProfile?> _getServerProfile(String deviceId) async {
    try {
      developer.log('서버에서 프로필 데이터 가져오기 시작: $deviceId',
          name: 'UserProfileRepository');

      // SyncManager를 통해 서버 데이터 가져오기
      final serverData = await _syncManager.getServerProfile(deviceId);
      if (serverData != null) {
        developer.log('서버에서 프로필 데이터 발견', name: 'UserProfileRepository');
        return UserProfile(
          deviceId: serverData['deviceId'] as String,
          username: serverData['username'] as String,
          createdAt: DateTime.parse(serverData['createdAt'] as String),
          lastLoginAt: DateTime.parse(serverData['lastLoginAt'] as String),
          totalPlayTime: serverData['totalPlayTime'] as int,
          completedPuzzles: serverData['completedPuzzles'] as int,
          currentStreak: serverData['currentStreak'] as int,
          bestStreak: serverData['bestStreak'] as int,
        );
      }
      developer.log('서버에 프로필 데이터 없음', name: 'UserProfileRepository');
      return null;
    } catch (e) {
      developer.log('서버에서 프로필 데이터 가져오기 실패: $e', name: 'UserProfileRepository');
      return null;
    }
  }

  /// 서버 데이터와 로컬 데이터 병합 (서버 우선 전략)
  Future<UserProfile> _mergeWithServerData(UserProfile localProfile) async {
    try {
      developer.log('서버 데이터와 로컬 데이터 병합 시작', name: 'UserProfileRepository');

      final serverProfile = await _getServerProfile(localProfile.deviceId);
      if (serverProfile == null) {
        developer.log('서버에 데이터 없음, 로컬 데이터 사용', name: 'UserProfileRepository');
        return localProfile;
      }

      // 서버 데이터 우선 전략으로 병합
      final mergedProfile = UserProfile(
        deviceId: localProfile.deviceId,
        username: localProfile.username, // 사용자 이름은 로컬 우선
        createdAt: serverProfile.createdAt.isBefore(localProfile.createdAt)
            ? serverProfile.createdAt
            : localProfile.createdAt,
        lastLoginAt: localProfile.lastLoginAt, // 마지막 로그인은 로컬 우선
        totalPlayTime:
            (serverProfile.totalPlayTime > localProfile.totalPlayTime)
                ? serverProfile.totalPlayTime
                : localProfile.totalPlayTime,
        completedPuzzles:
            (serverProfile.completedPuzzles > localProfile.completedPuzzles)
                ? serverProfile.completedPuzzles
                : localProfile.completedPuzzles,
        currentStreak:
            (serverProfile.currentStreak > localProfile.currentStreak)
                ? serverProfile.currentStreak
                : localProfile.currentStreak,
        bestStreak: (serverProfile.bestStreak > localProfile.bestStreak)
            ? serverProfile.bestStreak
            : localProfile.bestStreak,
      );

      developer.log('데이터 병합 완료:', name: 'UserProfileRepository');
      developer.log('  서버 completedPuzzles: ${serverProfile.completedPuzzles}',
          name: 'UserProfileRepository');
      developer.log('  로컬 completedPuzzles: ${localProfile.completedPuzzles}',
          name: 'UserProfileRepository');
      developer.log('  병합 completedPuzzles: ${mergedProfile.completedPuzzles}',
          name: 'UserProfileRepository');

      // 병합된 데이터를 로컬에 저장
      await _saveProfileToLocal(mergedProfile);

      return mergedProfile;
    } catch (e) {
      developer.log('서버 데이터 병합 실패: $e', name: 'UserProfileRepository');
      return localProfile;
    }
  }

  /// 프로필을 로컬에 저장
  Future<void> _saveProfileToLocal(UserProfile profile) async {
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
          'serverVersion': 1,
          'isDirty': 1, // 서버 동기화 필요
          'lastServerSync': null,
        },
      );
      developer.log('프로필 로컬 저장 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');
    } catch (e) {
      developer.log('프로필 로컬 저장 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 프로필을 동기화 큐에 추가 (배치 처리)
  Future<void> _queueProfileForSync(UserProfile profile) async {
    try {
      developer.log('프로필 동기화 큐에 추가: ${profile.deviceId}',
          name: 'UserProfileRepository');

      // 네트워크 상태 확인
      if (!_networkService.isOnline) {
        developer.log('오프라인 상태 - 동기화 큐에 저장', name: 'UserProfileRepository');
        await _syncManager.syncProfileUpdate({
          'deviceId': profile.deviceId,
          'username': profile.username,
          'createdAt': profile.createdAt.toIso8601String(),
          'lastLoginAt': profile.lastLoginAt.toIso8601String(),
          'totalPlayTime': profile.totalPlayTime,
          'completedPuzzles': profile.completedPuzzles,
          'currentStreak': profile.currentStreak,
          'bestStreak': profile.bestStreak,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
        return;
      }

      // 온라인 상태에서는 즉시 동기화 시도
      try {
        await _syncManager.addImmediateTask(SyncTask(
          type: SyncTaskType.profileUpdate,
          strategy: SyncStrategy.immediate,
          data: {
            'deviceId': profile.deviceId,
            'username': profile.username,
            'createdAt': profile.createdAt.toIso8601String(),
            'lastLoginAt': profile.lastLoginAt.toIso8601String(),
            'totalPlayTime': profile.totalPlayTime,
            'completedPuzzles': profile.completedPuzzles,
            'currentStreak': profile.currentStreak,
            'bestStreak': profile.bestStreak,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        ));

        // 서버 동기화 완료 후 로컬 상태 업데이트
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'isDirty': 0, // 서버와 동기화됨
            'lastServerSync': DateTime.now().toIso8601String(),
          },
          where: 'deviceId = ?',
          whereArgs: [profile.deviceId],
        );

        developer.log('프로필 즉시 동기화 완료: ${profile.deviceId}',
            name: 'UserProfileRepository');
      } catch (e) {
        developer.log('즉시 동기화 실패, 큐에 저장: $e', name: 'UserProfileRepository');
        // 즉시 동기화 실패 시 큐에 저장
        await _syncManager.syncProfileUpdate({
          'deviceId': profile.deviceId,
          'username': profile.username,
          'createdAt': profile.createdAt.toIso8601String(),
          'lastLoginAt': profile.lastLoginAt.toIso8601String(),
          'totalPlayTime': profile.totalPlayTime,
          'completedPuzzles': profile.completedPuzzles,
          'currentStreak': profile.currentStreak,
          'bestStreak': profile.bestStreak,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      developer.log('프로필 동기화 큐 추가 실패: $e', name: 'UserProfileRepository');
    }
  }
}

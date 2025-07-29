import 'dart:developer' as developer;
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/device_service.dart';
import 'package:chessudoku/data/services/firestore_service.dart';
import 'package:chessudoku/domain/repositories/user_profile_repository.dart';
import 'package:chessudoku/data/models/user_profile.dart';
import 'package:chessudoku/core/sync/sync_manager.dart';
import 'package:chessudoku/core/offline/offline_manager.dart';
import 'package:chessudoku/core/network/network_service.dart';

/// 사용자 프로필 Repository 구현체
class UserProfileRepositoryImpl implements UserProfileRepository {
  final DatabaseService _databaseService;
  final DeviceService _deviceService;
  final FirestoreService _firestoreService;
  final NetworkService _networkService;
  final SyncManager _syncManager = SyncManager();

  UserProfileRepositoryImpl(this._databaseService, this._deviceService,
      this._firestoreService, this._networkService);

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

        // 서버 동기화 시도
        await _syncWithServer(localProfile);

        // 동기화 후 최신 데이터 다시 조회
        final updatedResult = await _databaseService.query(
          DatabaseService.tableUserProfiles,
          where: 'deviceId = ?',
          whereArgs: [deviceId],
        );

        if (updatedResult.isNotEmpty) {
          final updatedData = updatedResult.first;
          return UserProfile(
            deviceId: updatedData['deviceId'] as String,
            username: updatedData['username'] as String,
            createdAt: DateTime.parse(updatedData['createdAt'] as String),
            lastLoginAt: DateTime.parse(updatedData['lastLoginAt'] as String),
            totalPlayTime: updatedData['totalPlayTime'] as int,
            completedPuzzles: updatedData['completedPuzzles'] as int,
            currentStreak: updatedData['currentStreak'] as int,
            bestStreak: updatedData['bestStreak'] as int,
          );
        }
      } else {
        // 로컬에 프로필이 없는 경우 - 서버에서 확인
        developer.log('로컬에 프로필 없음, 서버에서 확인: $deviceId',
            name: 'UserProfileRepository');
        final serverData = await _firestoreService.getUserData(deviceId);

        if (serverData != null) {
          // 서버에 데이터가 있으면 로컬에 저장
          developer.log('서버에서 기존 프로필 발견, 로컬에 저장',
              name: 'UserProfileRepository');
          final serverProfile = UserProfile(
            deviceId: serverData['deviceId'] as String,
            username: serverData['username'] as String,
            createdAt: DateTime.parse(serverData['createdAt'] as String),
            lastLoginAt: DateTime.parse(serverData['lastLoginAt'] as String),
            totalPlayTime: serverData['totalPlayTime'] as int,
            completedPuzzles: serverData['completedPuzzles'] as int,
            currentStreak: serverData['currentStreak'] as int,
            bestStreak: serverData['bestStreak'] as int,
          );

          // 로컬에 저장
          await _databaseService.insert(
            DatabaseService.tableUserProfiles,
            {
              'deviceId': serverProfile.deviceId,
              'username': serverProfile.username,
              'createdAt': serverProfile.createdAt.toIso8601String(),
              'lastLoginAt': serverProfile.lastLoginAt.toIso8601String(),
              'totalPlayTime': serverProfile.totalPlayTime,
              'completedPuzzles': serverProfile.completedPuzzles,
              'currentStreak': serverProfile.currentStreak,
              'bestStreak': serverProfile.bestStreak,
              'serverVersion': serverData['serverVersion'] as int? ?? 1,
              'isDirty': 0, // 서버와 동기화됨
              'lastServerSync': DateTime.now().toIso8601String(),
            },
          );

          developer.log('서버 프로필을 로컬에 저장 완료', name: 'UserProfileRepository');
          return serverProfile;
        }
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

      // 서버에 동기화
      await _syncToServer(profile.copyWith(
          // UserProfile 모델에 serverVersion 필드가 없으므로 별도 처리
          ));

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

        // 동기화 시스템을 통한 지연 동기화
        final updatedProfile =
            currentProfile.copyWith(completedPuzzles: newCompletedPuzzles);
        await _syncManager.syncProfileUpdate({
          'deviceId': updatedProfile.deviceId,
          'username': updatedProfile.username,
          'completedPuzzles': updatedProfile.completedPuzzles,
          'currentStreak': updatedProfile.currentStreak,
          'bestStreak': updatedProfile.bestStreak,
          'totalPlayTime': updatedProfile.totalPlayTime,
        });

        // 퍼즐 완료 동기화도 추가
        await _syncManager.syncPuzzleCompletion({
          'deviceId': deviceId,
          'completedAt': DateTime.now().toIso8601String(),
          'completedPuzzles': newCompletedPuzzles,
        });

        developer.log('완료한 퍼즐 수 동기화 완료', name: 'UserProfileRepository');
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

        // 동기화 시스템을 통한 지연 동기화
        final updatedProfile = currentProfile.copyWith(
          currentStreak: newStreak,
          bestStreak: bestStreak,
        );
        await _syncManager.syncProfileUpdate({
          'deviceId': updatedProfile.deviceId,
          'username': updatedProfile.username,
          'completedPuzzles': updatedProfile.completedPuzzles,
          'currentStreak': updatedProfile.currentStreak,
          'bestStreak': updatedProfile.bestStreak,
          'totalPlayTime': updatedProfile.totalPlayTime,
        });
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

        // 동기화 시스템을 통한 지연 동기화
        final updatedProfile =
            currentProfile.copyWith(totalPlayTime: newTotalPlayTime);
        await _syncManager.syncProfileUpdate({
          'deviceId': updatedProfile.deviceId,
          'username': updatedProfile.username,
          'completedPuzzles': updatedProfile.completedPuzzles,
          'currentStreak': updatedProfile.currentStreak,
          'bestStreak': updatedProfile.bestStreak,
          'totalPlayTime': updatedProfile.totalPlayTime,
        });
      }
    } catch (e) {
      developer.log('플레이 시간 업데이트 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 서버와 동기화 (개선된 버전)
  Future<void> _syncWithServer(UserProfile localProfile) async {
    try {
      // 네트워크 상태 확인
      if (!_networkService.isOnline) {
        developer.log('오프라인 상태 - 서버 동기화 건너뜀', name: 'UserProfileRepository');
        return;
      }

      developer.log('서버 동기화 시작', name: 'UserProfileRepository');

      // 서버에서 데이터 가져오기
      final serverData =
          await _firestoreService.getUserData(localProfile.deviceId);

      if (serverData != null) {
        // 서버 데이터가 있는 경우 스마트 동기화
        await _smartSync(localProfile, serverData);
      } else {
        // 서버에 데이터가 없으면 로컬 데이터를 서버에 저장
        developer.log('서버에 데이터 없음 - 로컬 데이터 업로드', name: 'UserProfileRepository');
        await _syncToServer(localProfile);
      }

      developer.log('서버 동기화 완료', name: 'UserProfileRepository');
    } catch (e) {
      developer.log('서버 동기화 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 스마트 동기화 로직 (데이터 손실 방지)
  Future<void> _smartSync(
      UserProfile localProfile, Map<String, dynamic> serverData) async {
    final serverVersion = serverData['serverVersion'] as int? ?? 0;
    final localVersion = await _getLocalVersion(localProfile.deviceId);

    final serverCompletedPuzzles = serverData['completedPuzzles'] as int? ?? 0;
    final localCompletedPuzzles = localProfile.completedPuzzles;

    developer.log(
        '스마트 동기화 - 로컬: $localCompletedPuzzles개($localVersion), 서버: $serverCompletedPuzzles개($serverVersion)',
        name: 'UserProfileRepository');

    // 데이터 손실 방지 로직
    if (_isDataLossScenario(localCompletedPuzzles, serverCompletedPuzzles,
        localVersion, serverVersion)) {
      developer.log('데이터 손실 시나리오 감지 - 서버 데이터 우선',
          name: 'UserProfileRepository');
      await _updateLocalFromServer(localProfile.deviceId, serverData);
      return;
    }

    // 일반적인 버전 비교
    if (serverVersion > localVersion) {
      developer.log('서버가 더 최신 - 서버 데이터로 로컬 업데이트',
          name: 'UserProfileRepository');
      await _updateLocalFromServer(localProfile.deviceId, serverData);
    } else if (localVersion > serverVersion) {
      developer.log('로컬이 더 최신 - 로컬 데이터로 서버 업데이트',
          name: 'UserProfileRepository');
      await _syncToServer(localProfile);
    } else {
      developer.log('버전 동일 - 데이터 병합 고려', name: 'UserProfileRepository');
      await _mergeDataIfNeeded(localProfile, serverData);
    }
  }

  /// 데이터 손실 시나리오 감지
  bool _isDataLossScenario(int localCompleted, int serverCompleted,
      int localVersion, int serverVersion) {
    // 로컬이 서버보다 훨씬 적은 퍼즐을 해결했는데, 로컬 버전이 더 높다면 의심
    if (localCompleted < serverCompleted && localVersion > serverVersion) {
      return true;
    }

    // 로컬이 0개인데 서버에 데이터가 있다면 의심
    if (localCompleted == 0 && serverCompleted > 0) {
      return true;
    }

    // 버전 차이가 너무 크면 의심 (예: 로컬 10, 서버 1)
    if (localVersion - serverVersion > 5) {
      return true;
    }

    return false;
  }

  /// 데이터 병합 (필요한 경우)
  Future<void> _mergeDataIfNeeded(
      UserProfile localProfile, Map<String, dynamic> serverData) async {
    final serverCompletedPuzzles = serverData['completedPuzzles'] as int? ?? 0;
    final localCompletedPuzzles = localProfile.completedPuzzles;

    // 더 높은 값으로 병합
    final mergedCompletedPuzzles =
        localCompletedPuzzles > serverCompletedPuzzles
            ? localCompletedPuzzles
            : serverCompletedPuzzles;

    if (mergedCompletedPuzzles != localCompletedPuzzles) {
      developer.log(
          '데이터 병합 - completedPuzzles: $localCompletedPuzzles → $mergedCompletedPuzzles',
          name: 'UserProfileRepository');

      final mergedProfile = localProfile.copyWith(
        completedPuzzles: mergedCompletedPuzzles,
      );

      await _syncToServer(mergedProfile);
    }
  }

  /// 서버에 데이터 동기화
  Future<void> _syncToServer(UserProfile profile) async {
    try {
      // 네트워크 상태 확인
      if (!_networkService.isOnline) {
        developer.log('오프라인 상태 - 서버 업로드 건너뜀', name: 'UserProfileRepository');
        return;
      }

      final userData = {
        'deviceId': profile.deviceId,
        'username': profile.username,
        'createdAt': profile.createdAt.toIso8601String(),
        'lastLoginAt': profile.lastLoginAt.toIso8601String(),
        'totalPlayTime': profile.totalPlayTime,
        'completedPuzzles': profile.completedPuzzles,
        'currentStreak': profile.currentStreak,
        'bestStreak': profile.bestStreak,
        'serverVersion': await _getLocalVersion(profile.deviceId),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _firestoreService.createOrUpdateUser(profile.deviceId, userData);

      // 동기화 완료 표시
      await _databaseService.update(
        DatabaseService.tableUserProfiles,
        {
          'isDirty': 0,
          'lastServerSync': DateTime.now().toIso8601String(),
        },
        where: 'deviceId = ?',
        whereArgs: [profile.deviceId],
      );

      developer.log('서버 동기화 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');
    } catch (e) {
      developer.log('서버 동기화 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 서버 데이터로 로컬 업데이트
  Future<void> _updateLocalFromServer(
      String deviceId, Map<String, dynamic> serverData) async {
    try {
      await _databaseService.update(
        DatabaseService.tableUserProfiles,
        {
          'username': serverData['username'],
          'lastLoginAt': serverData['lastLoginAt'],
          'totalPlayTime': serverData['totalPlayTime'],
          'completedPuzzles': serverData['completedPuzzles'],
          'currentStreak': serverData['currentStreak'],
          'bestStreak': serverData['bestStreak'],
          'serverVersion': serverData['serverVersion'],
          'isDirty': 0,
          'lastServerSync': DateTime.now().toIso8601String(),
        },
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );

      developer.log('서버 데이터로 로컬 업데이트 완료', name: 'UserProfileRepository');
    } catch (e) {
      developer.log('서버 데이터로 로컬 업데이트 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 로컬 버전 가져오기
  Future<int> _getLocalVersion(String deviceId) async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tableUserProfiles,
        columns: ['serverVersion'],
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );

      if (result.isNotEmpty) {
        return result.first['serverVersion'] as int;
      }
      return 0;
    } catch (e) {
      developer.log('로컬 버전 조회 실패: $e', name: 'UserProfileRepository');
      return 0;
    }
  }
}

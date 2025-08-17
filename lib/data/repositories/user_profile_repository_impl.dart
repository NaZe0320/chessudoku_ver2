import 'dart:developer' as developer;
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/device_service.dart';
import 'package:chessudoku/data/services/api_service.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/repositories/user_profile_repository.dart';
import 'package:chessudoku/data/models/user_profile.dart';
import 'package:chessudoku/core/sync/sync_manager.dart';
import 'package:chessudoku/core/network/network_service.dart';
import 'package:dio/dio.dart';

/// 사용자 프로필 Repository 구현체
class UserProfileRepositoryImpl implements UserProfileRepository {
  final DatabaseService _databaseService;
  final DeviceService _deviceService;
  final NetworkService _networkService;
  final SyncManager _syncManager;
  final ApiService _apiService;
  final CacheService _cacheService;

  UserProfileRepositoryImpl(
    this._databaseService,
    this._deviceService,
    this._networkService,
    this._syncManager,
    this._apiService,
    this._cacheService,
  );

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

          final newProfile = await _createUserProfileInternal(deviceId);
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
      // 내부 메서드를 사용하여 프로필 생성
      final createdProfile = await _createUserProfileInternal(profile.deviceId);
      return createdProfile;
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

  // ==================== 서버 통신 메서드 ====================

  /// 서버에서 프로필 데이터 가져오기 (HTTP API 사용)
  Future<UserProfile?> _getServerProfile(String deviceId) async {
    try {
      developer.log('서버에서 프로필 데이터 가져오기 시작: $deviceId',
          name: 'UserProfileRepository');

      if (!_networkService.isOnline) {
        developer.log('오프라인 상태 - 서버 데이터 가져오기 불가',
            name: 'UserProfileRepository');
        return null;
      }

      // HTTP API 호출
      final response = await _apiService.get('/account/$deviceId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // 서버 응답을 UserProfile 모델로 변환
        final serverProfile = UserProfile(
          deviceId: data['deviceId'] as String,
          username: data['username'] as String,
          createdAt: DateTime.parse(data['createdAt'] as String),
          lastLoginAt: DateTime.parse(data['lastLoginAt'] as String),
        );

        developer.log('서버에서 프로필 데이터 발견: $deviceId',
            name: 'UserProfileRepository');

        // 캐시에 저장
        await _cacheService.setString(
            'profile_$deviceId', response.data.toString());

        return serverProfile;
      } else if (response.statusCode == 404) {
        developer.log('서버에 프로필 데이터 없음: $deviceId',
            name: 'UserProfileRepository');
        return null;
      } else {
        developer.log('서버 응답 오류: ${response.statusCode}',
            name: 'UserProfileRepository');
        return null;
      }
    } catch (e) {
      developer.log('서버에서 프로필 데이터 가져오기 실패: $deviceId - $e',
          name: 'UserProfileRepository');

      // 캐시된 데이터 확인
      final cachedData = _cacheService.getString('profile_$deviceId');
      if (cachedData != null) {
        developer.log('캐시된 프로필 데이터 사용: $deviceId',
            name: 'UserProfileRepository');
        // 캐시된 데이터를 파싱하여 반환 (간단한 구현)
        // 실제로는 JSON 파싱이 필요
      }

      return null;
    }
  }

  /// 서버에 프로필 데이터 생성/업데이트 (HTTP API 사용)
  Future<bool> _createOrUpdateServerProfile(UserProfile profile) async {
    try {
      developer.log('서버에 프로필 데이터 생성/업데이트 시작: ${profile.deviceId}',
          name: 'UserProfileRepository');

      if (!_networkService.isOnline) {
        developer.log('오프라인 상태 - 서버 동기화 불가', name: 'UserProfileRepository');
        return false;
      }

      final profileData = {
        'deviceId': profile.deviceId,
        'username': profile.username,
        'createdAt': profile.createdAt.toIso8601String(),
        'lastLoginAt': profile.lastLoginAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      Response response;

      // 기존 프로필이 있는지 확인
      try {
        await _apiService.get('/account/${profile.deviceId}');
        // 기존 프로필이 있으면 업데이트
        response = await _apiService.put('/account/${profile.deviceId}',
            data: profileData);
      } catch (e) {
        // 기존 프로필이 없으면 생성
        response =
            await _apiService.post('/account/register', data: profileData);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('서버 프로필 동기화 성공: ${profile.deviceId}',
            name: 'UserProfileRepository');

        // 로컬 상태 업데이트
        await _databaseService.update(
          DatabaseService.tableUserProfiles,
          {
            'isDirty': 0, // 서버와 동기화됨
            'lastServerSync': DateTime.now().toIso8601String(),
          },
          where: 'deviceId = ?',
          whereArgs: [profile.deviceId],
        );

        return true;
      } else {
        developer.log('서버 프로필 동기화 실패: ${response.statusCode}',
            name: 'UserProfileRepository');
        return false;
      }
    } catch (e) {
      developer.log('서버 프로필 동기화 실패: ${profile.deviceId} - $e',
          name: 'UserProfileRepository');
      return false;
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
      );

      developer.log('데이터 병합 완료', name: 'UserProfileRepository');

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
          'lastUpdated': DateTime.now().toIso8601String(),
        });
        return;
      }

      // 온라인 상태에서는 즉시 동기화 시도
      try {
        final success = await _createOrUpdateServerProfile(profile);
        if (success) {
          developer.log('프로필 즉시 동기화 완료: ${profile.deviceId}',
              name: 'UserProfileRepository');
        } else {
          throw Exception('서버 동기화 실패');
        }
      } catch (e) {
        developer.log('즉시 동기화 실패, 큐에 저장: $e', name: 'UserProfileRepository');
        // 즉시 동기화 실패 시 큐에 저장
        await _syncManager.syncProfileUpdate({
          'deviceId': profile.deviceId,
          'username': profile.username,
          'createdAt': profile.createdAt.toIso8601String(),
          'lastLoginAt': profile.lastLoginAt.toIso8601String(),
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      developer.log('프로필 동기화 큐 추가 실패: $e', name: 'UserProfileRepository');
    }
  }

  /// 내부적으로 사용하는 프로필 생성 메서드
  Future<UserProfile> _createUserProfileInternal(String deviceId) async {
    try {
      developer.log('새 프로필 생성 시작: $deviceId', name: 'UserProfileRepository');

      UserProfile newProfile;

      if (_networkService.isOnline) {
        // 온라인 상태에서는 서버에 계정 생성 요청
        try {
          final response = await _apiService
              .post('/api/account/register', data: {'device_id': deviceId});

          if (response.statusCode == 201) {
            final responseData = response.data as Map<String, dynamic>;
            final accountData =
                responseData['data']['account'] as Map<String, dynamic>;

            // 서버 응답으로 프로필 생성
            newProfile = UserProfile(
              deviceId: deviceId,
              username: 'Player',
              createdAt: DateTime.parse(accountData['created_at'] as String),
              lastLoginAt: DateTime.now(),
            );

            developer.log('서버에서 계정 생성 완료: $deviceId',
                name: 'UserProfileRepository');
          } else {
            throw Exception('서버 계정 생성 실패: ${response.statusCode}');
          }
        } catch (e) {
          developer.log('서버 계정 생성 실패, 로컬에서 생성: $e',
              name: 'UserProfileRepository');
          // 서버 생성 실패 시 로컬에서 생성
          newProfile = UserProfile(
            deviceId: deviceId,
            username: 'Player',
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
        }
      } else {
        // 오프라인 상태에서는 로컬에서만 생성
        newProfile = UserProfile(
          deviceId: deviceId,
          username: 'Player',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }

      // 로컬에 저장
      await _saveProfileToLocal(newProfile);

      // 서버 동기화 큐에 추가
      await _queueProfileForSync(newProfile);

      developer.log('새 프로필 생성 완료: $deviceId', name: 'UserProfileRepository');
      return newProfile;
    } catch (e) {
      developer.log('프로필 생성 실패: $deviceId - $e', name: 'UserProfileRepository');
      rethrow;
    }
  }
}

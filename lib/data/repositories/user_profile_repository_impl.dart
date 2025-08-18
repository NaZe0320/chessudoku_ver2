import 'dart:developer' as developer;
import 'dart:convert';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/core/utils/device_utils.dart';
import 'package:chessudoku/data/services/api_service.dart';
import 'package:chessudoku/domain/repositories/user_profile_repository.dart';
import 'package:chessudoku/data/models/user_profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 사용자 프로필 Repository 구현체
class UserProfileRepositoryImpl implements UserProfileRepository {
  final DatabaseService _databaseService;
  final ApiService _apiService;

  UserProfileRepositoryImpl(
    this._databaseService,
    this._apiService,
  );

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      final deviceId = await DeviceUtils.getDeviceId();

      // 1. 로컬에서 프로필 조회
      final localProfile = await _getLocalProfile(deviceId);
      if (localProfile != null) {
        return localProfile;
      }

      // 2. 로컬에 없으면 새로 생성
      developer.log('로컬에 프로필 없음, 새 프로필 생성: $deviceId',
          name: 'UserProfileRepository');

      final newProfile = await _createNewProfile(deviceId);
      await _saveProfileToLocal(newProfile);
      return newProfile;
    } catch (e) {
      developer.log('사용자 프로필 조회 실패: $e', name: 'UserProfileRepository');
      return null;
    }
  }

  /// 로컬에서 프로필 조회
  Future<UserProfile?> _getLocalProfile(String deviceId) async {
    final result = await _databaseService.query(
      DatabaseService.tableUserProfiles,
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );

    if (result.isEmpty) return null;

    final data = result.first;
    return UserProfile(
      id: data['id'] as String,
      deviceId: data['deviceId'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      lastLoginAt: DateTime.parse(data['lastLoginAt'] as String),
      isPremium: (data['isPremium'] as int) == 1,
      settings: jsonDecode(data['settings'] as String) as Map<String, dynamic>,
    );
  }

  /// 새 프로필 생성 (서버 또는 로컬)
  Future<UserProfile> _createNewProfile(String deviceId) async {
    final connectivity = Connectivity();
    final isOnline =
        await connectivity.checkConnectivity() != ConnectivityResult.none;

    if (isOnline) {
      return await _createProfileWithServer(deviceId);
    } else {
      return _createProfileLocally(deviceId);
    }
  }

  /// 서버에서 프로필 생성
  Future<UserProfile> _createProfileWithServer(String deviceId) async {
    try {
      final response = await _apiService
          .post('/api/account/register', data: {'device_id': deviceId});

      if (response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final accountData =
            responseData['data']['account'] as Map<String, dynamic>;

        developer.log('서버에서 계정 생성 완료: $deviceId',
            name: 'UserProfileRepository');

        return UserProfile(
          id: accountData['id'] as String,
          deviceId: deviceId,
          createdAt: DateTime.parse(accountData['created_at'] as String),
          lastLoginAt: DateTime.now(),
          isPremium: accountData['is_premium'] as bool,
          settings: Map<String, dynamic>.from(accountData['settings'] as Map),
        );
      } else {
        throw Exception('서버 계정 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('서버 계정 생성 실패, 로컬에서 생성: $e', name: 'UserProfileRepository');
      return _createProfileLocally(deviceId);
    }
  }

  /// 로컬에서 프로필 생성
  UserProfile _createProfileLocally(String deviceId) {
    developer.log('로컬에서 프로필 생성: $deviceId', name: 'UserProfileRepository');

    return UserProfile(
      id: '', // 임시 ID
      deviceId: deviceId,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isPremium: false,
      settings: {},
    );
  }

  /// 프로필을 로컬에 저장
  Future<void> _saveProfileToLocal(UserProfile profile) async {
    try {
      await _databaseService.insert(
        DatabaseService.tableUserProfiles,
        {
          'id': profile.id,
          'deviceId': profile.deviceId,
          'createdAt': profile.createdAt.toIso8601String(),
          'lastLoginAt': profile.lastLoginAt.toIso8601String(),
          'isPremium': profile.isPremium ? 1 : 0,
          'settings': jsonEncode(profile.settings),
        },
      );
      developer.log('프로필 로컬 저장 완료: ${profile.deviceId}',
          name: 'UserProfileRepository');
    } catch (e) {
      developer.log('프로필 로컬 저장 실패: $e', name: 'UserProfileRepository');
    }
  }
}

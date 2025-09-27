import 'dart:developer' as developer;
import 'package:chessudoku/domain/repositories/user_repository.dart';
import 'package:chessudoku/domain/entities/user.dart';
import 'package:chessudoku/data/services/api_service.dart';
import 'package:chessudoku/core/config/api_endpoints.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 서버 API를 사용한 사용자 repository 구현체
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<User?> getUserByDeviceId(String deviceId) async {
    try {
      developer.log('디바이스 ID로 사용자 조회 + 자동 등록: $deviceId',
          name: 'UserRepository');

      // 네트워크 연결 확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('네트워크 연결 없음', name: 'UserRepository');
        return null;
      }

      // 서버에서 사용자 조회 + 자동 등록
      final response =
          await _apiService.get('${ApiEndpoints.userByDeviceId}/$deviceId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        developer.log('🔍 [TEST] 서버 응답 데이터: $responseData',
            name: 'UserRepository');

        // success 필드 확인
        final hasSuccess = responseData.containsKey('success');
        final successValue = responseData['success'];
        developer.log('🔍 [TEST] success 필드 존재: $hasSuccess, 값: $successValue',
            name: 'UserRepository');

        if (responseData['success'] == true) {
          final user = User.fromServerResponse(responseData);
          developer.log('✅ [TEST] 사용자 조회/등록 완료: ${user.userId}',
              name: 'UserRepository');
          return user;
        } else {
          developer.log(
              '❌ [TEST] success가 true가 아님 - success: ${responseData['success']}',
              name: 'UserRepository');

          // success 필드가 없다면 data 필드만으로 처리 시도
          if (!hasSuccess && responseData.containsKey('data')) {
            developer.log('🔧 [TEST] success 필드 없음, data 필드로 사용자 생성 시도',
                name: 'UserRepository');
            try {
              final user = User.fromServerResponse(responseData);
              developer.log('✅ [TEST] data 필드로 사용자 생성 성공: ${user.userId}',
                  name: 'UserRepository');
              return user;
            } catch (e) {
              developer.log('💥 [TEST] data 필드로 사용자 생성 실패: $e',
                  name: 'UserRepository');
            }
          }
        }
      }

      developer.log('❌ [TEST] 사용자 조회/등록 실패: ${response.statusCode}',
          name: 'UserRepository');
      return null;
    } catch (e) {
      developer.log('사용자 조회/등록 실패: $e', name: 'UserRepository');
      return null;
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      developer.log('사용자 ID로 조회: $userId', name: 'UserRepository');

      // 네트워크 연결 확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('네트워크 연결 없음', name: 'UserRepository');
        return null;
      }

      // 서버에서 사용자 조회
      final response =
          await _apiService.get('${ApiEndpoints.userById}/$userId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final user = User.fromServerResponse(responseData);
          developer.log('사용자 조회 완료: ${user.userId}', name: 'UserRepository');
          return user;
        }
      }

      developer.log('사용자 조회 실패: ${response.statusCode}',
          name: 'UserRepository');
      return null;
    } catch (e) {
      developer.log('사용자 조회 실패: $e', name: 'UserRepository');
      return null;
    }
  }

  @override
  Future<bool> withdrawUser(String userId) async {
    try {
      developer.log('사용자 탈퇴: $userId', name: 'UserRepository');

      // 네트워크 연결 확인
      final connectivity = Connectivity();
      final isOnline =
          await connectivity.checkConnectivity() != ConnectivityResult.none;

      if (!isOnline) {
        developer.log('네트워크 연결 없음', name: 'UserRepository');
        return false;
      }

      // 서버에서 사용자 탈퇴
      final response =
          await _apiService.delete('${ApiEndpoints.userById}/$userId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          developer.log('사용자 탈퇴 완료: $userId', name: 'UserRepository');
          return true;
        }
      }

      developer.log('사용자 탈퇴 실패: ${response.statusCode}',
          name: 'UserRepository');
      return false;
    } catch (e) {
      developer.log('사용자 탈퇴 실패: $e', name: 'UserRepository');
      return false;
    }
  }
}

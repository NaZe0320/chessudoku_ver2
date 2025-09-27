import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/user_service.dart';
import '../../main.dart'; // DatabaseService 전역 함수를 위해 임포트
import 'repository_providers.dart';

// ==================== Core Services ====================

/// DatabaseService Provider - 전역 인스턴스 사용
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = getGlobalDatabaseService(); // 이미 초기화된 전역 인스턴스 사용
  // 앱 종료 시 정리 작업을 위한 리스너 등록
  ref.onDispose(() {
    // 데이터베이스 연결 정리
    service.close();
  });
  return service;
});

/// CacheService Provider - Singleton 인스턴스 사용
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.getInstance(); // Singleton 인스턴스 사용
});

/// ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// UserService Provider
final userServiceProvider = Provider<UserService>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final cacheService = ref.watch(cacheServiceProvider);

  return UserService(userRepository, cacheService);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/user_service.dart';
import 'repository_providers.dart';

// ==================== Core Services ====================

/// DatabaseService Provider - 앱 시작 시 초기화
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();
  // 앱 종료 시 정리 작업을 위한 리스너 등록
  ref.onDispose(() {
    // 데이터베이스 연결 정리
    service.close();
  });
  return service;
});

/// CacheService Provider - 앱 시작 시 초기화
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  // 앱 시작 시 캐시 서비스 초기화
  service.init();
  return service;
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

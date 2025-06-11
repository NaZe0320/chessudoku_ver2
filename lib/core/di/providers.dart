import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/test_service.dart';
import '../../data/repositories/test_repository_impl.dart';
import '../../domain/repositories/test_repository.dart';
import '../../data/repositories/version_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/device_service.dart';
import '../../domain/repositories/version_repository.dart';

/// TestService Provider
final testServiceProvider = Provider<TestService>((ref) {
  return TestService();
});

/// CacheService Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// DeviceService Provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

/// DatabaseService Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// VersionRepository Provider
final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final testService = ref.watch(testServiceProvider);
  // final apiService = ref.watch(apiServiceProvider); // 실제 서버 연동 시 TestService 대신 사용

  return VersionRepositoryImpl(
    databaseService: databaseService,
    testService: testService,
  );
});

/// TestRepository Provider
final testRepositoryProvider = Provider<TestRepository>((ref) {
  final testService = ref.watch(testServiceProvider);
  return TestRepositoryImpl(testService);
});

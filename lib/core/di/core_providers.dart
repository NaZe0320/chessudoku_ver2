import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/firestore_service.dart';
import '../../core/network/network_service.dart';
import '../../core/initialization/app_initializer.dart';

/// DatabaseService Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// DeviceService Provider
final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

/// CacheService Provider
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// FirestoreService Provider (기존 호환성을 위해 유지)
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// NetworkService Provider
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// AppInitializer Provider
final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer();
});

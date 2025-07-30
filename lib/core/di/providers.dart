import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/test_service.dart';
import '../../data/repositories/test_repository_impl.dart';
import '../../domain/repositories/test_repository.dart';
import '../../data/repositories/version_repository_impl.dart';
import '../../data/repositories/game_save_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../data/repositories/puzzle_record_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/repositories/version_repository.dart';
import '../../domain/repositories/game_save_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/puzzle_record_repository.dart';
import '../../domain/notifiers/sync_notifier.dart';
import '../../domain/states/sync_state.dart';
import '../../domain/notifiers/main_notifier.dart';
import '../../domain/states/main_state.dart';
import './language_pack_provider.dart';
import '../network/network_service.dart';
import '../sync/sync_manager.dart';
import '../sync/sync_queue.dart';

import '../initialization/app_initializer.dart';

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

/// FirestoreService Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// VersionRepository Provider
final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final languageRepository = ref.watch(languageRepositoryProvider);

  return VersionRepositoryImpl(
    databaseService: databaseService,
    firestoreService: firestoreService,
    languageRepository: languageRepository,
  );
});

/// SyncNotifier Provider
final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final versionRepository = ref.watch(versionRepositoryProvider);
  return SyncNotifier(versionRepository: versionRepository);
});

/// TestRepository Provider
final testRepositoryProvider = Provider<TestRepository>((ref) {
  final testService = ref.watch(testServiceProvider);
  return TestRepositoryImpl(testService);
});

/// GameSaveRepository Provider
final gameSaveRepositoryProvider = Provider<GameSaveRepository>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return GameSaveRepositoryImpl(cacheService);
});

/// UserProfileRepository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final deviceService = ref.watch(deviceServiceProvider);
  final networkService = ref.watch(networkServiceProvider);
  final syncManager = ref.watch(syncManagerProvider);
  return UserProfileRepositoryImpl(
      databaseService, deviceService, networkService, syncManager);
});

/// PuzzleRecordRepository Provider
final puzzleRecordRepositoryProvider = Provider<PuzzleRecordRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return PuzzleRecordRepositoryImpl(databaseService);
});

/// MainNotifier Provider
final mainNotifierProvider =
    StateNotifierProvider<MainNotifier, MainState>((ref) {
  final gameSaveRepository = ref.watch(gameSaveRepositoryProvider);
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  return MainNotifier(gameSaveRepository, userProfileRepository);
});

/// NetworkService Provider
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// SyncManager Provider
final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager();
});

/// SyncQueue Provider
final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

/// AppInitializer Provider
final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer();
});

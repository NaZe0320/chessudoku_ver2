import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/test_service.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../data/repositories/version_repository_impl.dart';
import '../../data/repositories/game_save_repository_impl.dart';
import '../../data/repositories/puzzle_record_repository_impl.dart';
import '../../data/repositories/puzzle_repository_impl.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/version_repository.dart';
import '../../domain/repositories/game_save_repository.dart';
import '../../domain/repositories/puzzle_record_repository.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../../domain/notifiers/main_notifier.dart';
import '../../domain/notifiers/game_preparation_notifier.dart';
import '../../domain/notifiers/sync_notifier.dart';
import '../../domain/notifiers/game_settings_notifier.dart';
import '../../domain/states/sync_state.dart';
import '../../domain/states/main_state.dart';
import '../../domain/states/game_preparation_state.dart';
import '../../domain/states/game_settings_state.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/sync/sync_queue.dart';
import '../../core/network/network_service.dart';
import '../../core/initialization/app_initializer.dart';
import '../../data/repositories/language_repository_impl.dart';
import '../../domain/repositories/language_repository.dart';

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

/// LanguageRepository Provider
final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return LanguageRepositoryImpl(databaseService);
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

/// GameSaveRepository Provider
final gameSaveRepositoryProvider = Provider<GameSaveRepository>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return GameSaveRepositoryImpl(cacheService);
});

/// SyncManager Provider
final syncManagerProvider = Provider<SyncManager>((ref) {
  final syncManager = SyncManager();
  // ApiService 설정
  final apiService = ref.watch(apiServiceProvider);
  syncManager.setApiService(apiService);
  return syncManager;
});

/// UserProfileRepository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final deviceService = ref.watch(deviceServiceProvider);
  final networkService = ref.watch(networkServiceProvider);
  final syncManager = ref.watch(syncManagerProvider);
  final apiService = ref.watch(apiServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);

  return UserProfileRepositoryImpl(
    databaseService,
    deviceService,
    networkService,
    syncManager,
    apiService,
    cacheService,
  );
});

/// PuzzleRecordRepository Provider
final puzzleRecordRepositoryProvider = Provider<PuzzleRecordRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return PuzzleRecordRepositoryImpl(databaseService);
});

/// PuzzleRepository Provider
final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return PuzzleRepositoryImpl(firestoreService: firestoreService);
});

/// MainNotifier Provider
final mainNotifierProvider =
    StateNotifierProvider<MainNotifier, MainState>((ref) {
  final gameSaveRepository = ref.watch(gameSaveRepositoryProvider);
  return MainNotifier(gameSaveRepository);
});

/// GamePreparationNotifier Provider
final gamePreparationNotifierProvider =
    StateNotifierProvider<GamePreparationNotifier, GamePreparationState>((ref) {
  final gameSaveRepository = ref.watch(gameSaveRepositoryProvider);
  final puzzleRepository = ref.watch(puzzleRepositoryProvider);
  final networkService = ref.watch(networkServiceProvider);
  return GamePreparationNotifier(
    gameSaveRepository: gameSaveRepository,
    puzzleRepository: puzzleRepository,
    puzzleRecordRepository: ref.watch(puzzleRecordRepositoryProvider),
    networkService: networkService,
  );
});

/// GameSettingsNotifier Provider
final gameSettingsNotifierProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettingsState>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return GameSettingsNotifier(cacheService);
});

/// NetworkService Provider
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// SyncQueue Provider
final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

/// AppInitializer Provider
final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer();
});

/// TestService Provider
final testServiceProvider = Provider<TestService>((ref) {
  return TestService();
});

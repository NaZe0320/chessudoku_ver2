import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
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

import '../../core/initialization/app_initializer.dart';
import '../../data/repositories/language_repository_impl.dart';
import '../../domain/repositories/language_repository.dart';

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

/// FirestoreService Provider (기존 호환성을 위해 유지)
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ==================== Repositories ====================

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

/// GameSaveRepository Provider
final gameSaveRepositoryProvider = Provider<GameSaveRepository>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return GameSaveRepositoryImpl(cacheService);
});

/// UserProfileRepository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final apiService = ref.watch(apiServiceProvider);

  return UserProfileRepositoryImpl(
    databaseService,
    apiService,
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

// ==================== Business Logic ====================

/// SyncNotifier Provider
final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final versionRepository = ref.watch(versionRepositoryProvider);
  return SyncNotifier(versionRepository: versionRepository);
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
  return GamePreparationNotifier(
    gameSaveRepository: gameSaveRepository,
    puzzleRepository: puzzleRepository,
    puzzleRecordRepository: ref.watch(puzzleRecordRepositoryProvider),
  );
});

/// GameSettingsNotifier Provider
final gameSettingsNotifierProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettingsState>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return GameSettingsNotifier(cacheService);
});

// ==================== Infrastructure ====================

/// AppInitializer Provider - 앱 초기화
final appInitializerProvider = Provider<AppInitializer>((ref) {
  return AppInitializer();
});

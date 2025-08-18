import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/language_repository_impl.dart';
import '../../data/repositories/version_repository_impl.dart';
import '../../data/repositories/game_save_repository_impl.dart';
import '../../data/repositories/puzzle_record_repository_impl.dart';
import '../../data/repositories/puzzle_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/language_repository.dart';
import '../../domain/repositories/version_repository.dart';
import '../../domain/repositories/game_save_repository.dart';
import '../../domain/repositories/puzzle_record_repository.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'core_providers.dart';

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
  final deviceService = ref.watch(deviceServiceProvider);
  final apiService = ref.watch(apiServiceProvider);

  return UserProfileRepositoryImpl(
    databaseService,
    deviceService,
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

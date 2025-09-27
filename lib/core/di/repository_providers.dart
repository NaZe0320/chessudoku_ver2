import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/version_repository_impl.dart';
import '../../data/repositories/game_save_repository_impl.dart';
import '../../data/repositories/puzzle_repository_impl.dart';
import '../../data/repositories/language_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/version_repository.dart';
import '../../domain/repositories/game_save_repository.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../../domain/repositories/language_repository.dart';
import 'service_providers.dart';

// ==================== Repositories ====================

/// LanguageRepository Provider
final languageRepositoryProvider = Provider<LanguageRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return LanguageRepositoryImpl(databaseService);
});

/// VersionRepository Provider
final versionRepositoryProvider = Provider<VersionRepository>((ref) {
  final languageRepository = ref.watch(languageRepositoryProvider);

  return VersionRepositoryImpl(
    languageRepository: languageRepository,
  );
});

/// GameSaveRepository Provider
final gameSaveRepositoryProvider = Provider<GameSaveRepository>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return GameSaveRepositoryImpl(cacheService);
});

/// UserRepository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return UserRepositoryImpl(apiService);
});

/// PuzzleRepository Provider
final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PuzzleRepositoryImpl(apiService);
});

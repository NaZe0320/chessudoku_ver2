import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/notifiers/main_notifier.dart';
import '../../presentation/notifiers/game_preparation_notifier.dart';
import '../../presentation/notifiers/sync_notifier.dart';
import '../../presentation/notifiers/game_settings_notifier.dart';
import '../../presentation/states/sync_state.dart';
import '../../presentation/states/main_state.dart';
import '../../presentation/states/game_preparation_state.dart';
import '../../presentation/states/game_settings_state.dart';
import 'repository_providers.dart';
import 'service_providers.dart';

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

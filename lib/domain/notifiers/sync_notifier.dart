import 'package:chessudoku/domain/repositories/version_repository.dart';
import 'package:chessudoku/domain/states/sync_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncNotifier extends StateNotifier<SyncState> {
  final VersionRepository _versionRepository;

  SyncNotifier({
    required VersionRepository versionRepository,
  })  : _versionRepository = versionRepository,
        super(const SyncState());

  Future<void> startSync() async {
    await _versionRepository.checkVersionAndSync(
      onProgress: (progress, message) {
        state = state.copyWith(
          progress: progress,
          message: message,
          isCompleted: progress >= 1.0,
        );
      },
    );
  }
}

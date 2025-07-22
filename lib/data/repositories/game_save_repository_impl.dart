import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/states/game_state.dart';

/// 게임 저장/로드를 위한 Repository 구현체
class GameSaveRepositoryImpl implements GameSaveRepository {
  final CacheService _cacheService;

  GameSaveRepositoryImpl(this._cacheService);

  @override
  Future<bool> saveCurrentGame(GameState gameState) async {
    // TODO: 게임 상태 저장 구현
    return false;
  }

  @override
  GameState? loadCurrentGame() {
    // TODO: 게임 상태 로드 구현
    return null;
  }

  @override
  Future<bool> clearCurrentGame() async {
    // TODO: 게임 상태 삭제 구현
    return false;
  }
}

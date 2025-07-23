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

  @override
  Future<bool> hasSavedGame() async {
    // TODO: 저장된 게임 존재 여부 확인 구현
    // 임시로 true 반환 (테스트용)
    return true;
  }

  @override
  Future<String?> getSavedGameInfo() async {
    // TODO: 저장된 게임 정보 가져오기 구현
    // 임시로 테스트 데이터 반환
    return '보통 난이도 • 8번 정답 • 65% 완료';
  }

  @override
  Future<int> getCompletedPuzzlesCount() async {
    // TODO: 완료한 퍼즐 수 가져오기 구현
    return 0;
  }

  @override
  Future<int> getCurrentStreak() async {
    // TODO: 현재 연속 기록 가져오기 구현
    return 0;
  }
}

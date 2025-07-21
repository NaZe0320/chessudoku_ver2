import 'package:chessudoku/domain/states/game_state.dart';

/// 게임 저장/로드를 위한 Repository 인터페이스
abstract class GameSaveRepository {
  /// 현재 게임 상태 저장
  Future<bool> saveCurrentGame(GameState gameState);

  /// 현재 게임 상태 로드
  GameState? loadCurrentGame();

  /// 현재 게임 삭제
  Future<bool> clearCurrentGame();
}

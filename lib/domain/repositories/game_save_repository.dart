import 'package:chessudoku/application/states/game_state.dart';
import 'package:chessudoku/domain/entities/saved_game_data.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

/// 게임 저장/로드를 위한 Repository 인터페이스
abstract class GameSaveRepository {
  /// 현재 게임 상태 저장
  Future<bool> saveCurrentGame(GameState gameState, Difficulty difficulty);

  /// 현재 게임 상태 로드
  SavedGameData? loadCurrentGame();

  /// 현재 게임 삭제
  Future<bool> clearCurrentGame();

  /// 저장된 게임 존재 여부 확인
  Future<bool> hasSavedGame();

}

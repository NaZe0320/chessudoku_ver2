import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/data/models/saved_game_data.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

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

  /// 저장된 게임 정보 가져오기
  Future<String?> getSavedGameInfo();

  /// 완료한 퍼즐 수 가져오기
  Future<int> getCompletedPuzzlesCount();

  /// 현재 연속 기록 가져오기
  Future<int> getCurrentStreak();

  // 난이도별 저장 메서드들
  /// 난이도별 게임 저장
  Future<bool> saveGameByDifficulty(SavedGameData game, Difficulty difficulty);

  /// 난이도별 저장된 게임 조회
  SavedGameData? getSavedGameByDifficulty(Difficulty difficulty);

  /// 가장 최근 플레이한 게임 조회
  SavedGameData? getLatestPlayedGame();

  /// 가장 최근 플레이한 게임 타입 조회
  String? getLastPlayedType();

  /// 난이도별 저장된 게임 존재 여부 확인
  Future<bool> hasSavedGameByDifficulty(Difficulty difficulty);

  /// 가장 최근 플레이한 게임 타입 저장
  Future<bool> saveLastPlayedType(String type);

  /// 특정 난이도의 저장된 게임 삭제
  Future<bool> clearGameByDifficulty(Difficulty difficulty);
}

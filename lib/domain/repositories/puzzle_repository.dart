import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐 관리를 위한 Repository 인터페이스
abstract class PuzzleRepository {
  /// Firebase에서 퍼즐 가져오기
  Future<GameBoard?> getPuzzleFromFirebase(Difficulty difficulty);

  /// 로컬에 퍼즐 캐시 저장
  Future<void> cachePuzzle(GameBoard puzzle, Difficulty difficulty);

  /// 캐시된 퍼즐 가져오기
  GameBoard? getCachedPuzzle(Difficulty difficulty);

  /// 캐시된 퍼즐 존재 여부 확인
  bool hasCachedPuzzle(Difficulty difficulty);

  /// 캐시된 퍼즐 삭제
  Future<void> clearCachedPuzzle(Difficulty difficulty);
}

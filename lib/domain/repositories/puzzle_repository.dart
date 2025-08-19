import 'package:chessudoku/domain/entities/puzzle.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

/// 퍼즐 데이터 접근을 위한 repository 인터페이스
abstract class PuzzleRepository {
  /// 특정 퍼즐 가져오기
  Future<Puzzle?> getPuzzleById(String puzzleId, Difficulty difficulty);

  /// 난이도별 랜덤 퍼즐 가져오기
  Future<Puzzle?> getRandomPuzzleByDifficulty(Difficulty difficulty);

  /// 난이도별 퍼즐 목록 가져오기
  Future<List<Puzzle>> getPuzzlesByDifficulty(Difficulty difficulty,
      {int limit = 10});
}

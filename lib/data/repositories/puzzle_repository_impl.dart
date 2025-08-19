import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/domain/entities/puzzle.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

/// 로컬 데이터베이스를 사용한 퍼즐 repository 구현체
class PuzzleRepositoryImpl implements PuzzleRepository {
  PuzzleRepositoryImpl();

  @override
  Future<Puzzle?> getPuzzleById(String puzzleId, Difficulty difficulty) async {
    // 로컬 데이터베이스에서 퍼즐 조회 (구현 필요)
    return null;
  }

  @override
  Future<Puzzle?> getRandomPuzzleByDifficulty(Difficulty difficulty) async {
    // 로컬 데이터베이스에서 랜덤 퍼즐 조회 (구현 필요)
    return null;
  }

  @override
  Future<List<Puzzle>> getPuzzlesByDifficulty(Difficulty difficulty,
      {int limit = 10}) async {
    // 로컬 데이터베이스에서 난이도별 퍼즐 목록 조회 (구현 필요)
    return [];
  }
}

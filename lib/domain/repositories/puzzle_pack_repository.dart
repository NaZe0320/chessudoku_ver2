import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐팩 데이터 관리를 위한 Repository 인터페이스
abstract class PuzzlePackRepository {
  /// 모든 퍼즐팩 조회
  Future<List<PuzzlePack>> getAllPuzzlePacks();

  /// 난이도별 퍼즐팩 조회
  Future<List<PuzzlePack>> getPuzzlePacksByDifficulty(Difficulty difficulty);

  /// 타입별 퍼즐팩 조회
  Future<List<PuzzlePack>> getPuzzlePacksByType(String type);

  /// 추천 퍼즐팩 조회
  Future<List<PuzzlePack>> getRecommendedPuzzlePacks();

  /// 프리미엄 퍼즐팩 조회
  Future<List<PuzzlePack>> getPremiumPuzzlePacks();

  /// 특정 퍼즐팩 조회
  Future<PuzzlePack?> getPuzzlePackById(String id);

  /// 퍼즐팩 진행률 업데이트
  Future<void> updatePuzzlePackProgress(String id, int completedPuzzles);
}

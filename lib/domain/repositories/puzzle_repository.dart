import 'package:chessudoku/domain/entities/puzzle.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

/// 퍼즐 데이터 접근을 위한 repository 인터페이스
abstract class PuzzleRepository {
  /// 조건에 맞는 랜덤 퍼즐 가져오기
  /// [puzzleType] 퍼즐 타입 (normal, daily_challenge)
  /// [difficulty] 퍼즐 난이도
  Future<Puzzle?> getRandomPuzzle({
    String? puzzleType,
    Difficulty? difficulty,
  });

  /// 데일리 퍼즐 가져오기
  /// [date] 조회할 날짜 (null이면 오늘 날짜)
  Future<Puzzle?> getDailyPuzzle({DateTime? date});
}

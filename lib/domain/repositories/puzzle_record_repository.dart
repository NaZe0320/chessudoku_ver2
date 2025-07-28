import 'package:chessudoku/data/models/puzzle_record.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐 기록 관리를 위한 Repository 인터페이스
abstract class PuzzleRecordRepository {
  /// 모든 퍼즐 기록 조회
  Future<List<PuzzleRecord>> getAllRecords();

  /// 난이도별 퍼즐 기록 조회
  Future<List<PuzzleRecord>> getRecordsByDifficulty(Difficulty difficulty);

  /// 특정 퍼즐의 최고 기록 조회
  Future<PuzzleRecord?> getBestRecord(String puzzleId);

  /// 퍼즐 기록 저장
  Future<void> savePuzzleRecord(PuzzleRecord record);

  /// 완료한 퍼즐 수 조회
  Future<int> getCompletedPuzzlesCount();

  /// 현재 연속 기록 조회
  Future<int> getCurrentStreak();

  /// 최고 연속 기록 조회
  Future<int> getBestStreak();
}

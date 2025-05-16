import 'package:chessudoku/data/models/puzzle_record.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/legacy/puzzle_state.dart';

/// 퍼즐 기록 관리를 위한 추상 인터페이스
abstract class RecordRepository {
  /// 완료된 퍼즐 기록 저장
  Future<bool> savePuzzleRecord(PuzzleState state);

  /// 특정 난이도의 모든 퍼즐 기록 조회
  Future<List<PuzzleRecord>> getRecordsByDifficulty(Difficulty difficulty);

  /// 모든 퍼즐 기록 조회
  Future<List<PuzzleRecord>> getAllRecords();

  /// 특정 난이도의 최고 기록 조회
  Future<PuzzleRecord?> getBestRecordByDifficulty(Difficulty difficulty);

  /// 퍼즐 기록 삭제
  Future<bool> deleteRecord(int id);

  /// 특정 난이도의 모든 퍼즐 기록 삭제
  Future<bool> deleteRecordsByDifficulty(Difficulty difficulty);

  /// 모든 퍼즐 기록 삭제
  Future<bool> clearAllRecords();
}

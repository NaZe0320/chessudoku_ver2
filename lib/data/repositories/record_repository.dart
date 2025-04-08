import 'package:chessudoku/data/models/puzzle_record.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';

/// 퍼즐 기록 관리를 담당하는 저장소
class RecordRepository {
  // 의존성 주입
  final DatabaseService _databaseService;

  // 생성자
  RecordRepository(this._databaseService);

  /// 완료된 퍼즐 기록 저장
  Future<bool> savePuzzleRecord(PuzzleState state) async {
    try {
      // 퍼즐 상태를 레코드로 변환
      final record = PuzzleRecord(
        difficulty: state.difficulty,
        boardData: state.board,
        completionTime: state.elapsedTime,
        createdAt: DateTime.now(),
      );

      // 데이터베이스에 저장
      final id = await _databaseService.insert(
        DatabaseService.tablePuzzleRecords,
        record.toMap(),
      );

      return id > 0;
    } catch (e) {
      print('퍼즐 기록 저장 중 오류 발생: $e');
      return false;
    }
  }

  /// 특정 난이도의 모든 퍼즐 기록 조회
  Future<List<PuzzleRecord>> getRecordsByDifficulty(
      Difficulty difficulty) async {
    try {
      final records = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        where: 'difficulty = ?',
        whereArgs: [difficulty.name],
        orderBy: 'completionTime ASC',
      );

      return records.map((r) => PuzzleRecord.fromMap(r)).toList();
    } catch (e) {
      print('퍼즐 기록 조회 중 오류 발생: $e');
      return [];
    }
  }

  /// 모든 퍼즐 기록 조회
  Future<List<PuzzleRecord>> getAllRecords() async {
    try {
      final records = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        orderBy: 'createdAt DESC',
      );

      return records.map((r) => PuzzleRecord.fromMap(r)).toList();
    } catch (e) {
      print('퍼즐 기록 조회 중 오류 발생: $e');
      return [];
    }
  }

  /// 특정 난이도의 최고 기록 조회
  Future<PuzzleRecord?> getBestRecordByDifficulty(Difficulty difficulty) async {
    try {
      final records = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        where: 'difficulty = ?',
        whereArgs: [difficulty.name],
        orderBy: 'completionTime ASC',
        limit: 1,
      );

      if (records.isEmpty) {
        return null;
      }

      return PuzzleRecord.fromMap(records.first);
    } catch (e) {
      print('최고 기록 조회 중 오류 발생: $e');
      return null;
    }
  }

  /// 퍼즐 기록 삭제
  Future<bool> deleteRecord(int id) async {
    try {
      final count = await _databaseService.delete(
        DatabaseService.tablePuzzleRecords,
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      print('퍼즐 기록 삭제 중 오류 발생: $e');
      return false;
    }
  }

  /// 특정 난이도의 모든 퍼즐 기록 삭제
  Future<bool> deleteRecordsByDifficulty(Difficulty difficulty) async {
    try {
      final count = await _databaseService.delete(
        DatabaseService.tablePuzzleRecords,
        where: 'difficulty = ?',
        whereArgs: [difficulty.name],
      );

      return count > 0;
    } catch (e) {
      print('퍼즐 기록 삭제 중 오류 발생: $e');
      return false;
    }
  }

  /// 모든 퍼즐 기록 삭제
  Future<bool> clearAllRecords() async {
    try {
      await _databaseService.delete(DatabaseService.tablePuzzleRecords);
      return true;
    } catch (e) {
      print('모든 퍼즐 기록 삭제 중 오류 발생: $e');
      return false;
    }
  }
}

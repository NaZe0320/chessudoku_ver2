import 'dart:developer' as developer;
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/domain/repositories/puzzle_record_repository.dart';
import 'package:chessudoku/data/models/puzzle_record.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐 기록 Repository 구현체
class PuzzleRecordRepositoryImpl implements PuzzleRecordRepository {
  final DatabaseService _databaseService;

  PuzzleRecordRepositoryImpl(this._databaseService);

  @override
  Future<List<PuzzleRecord>> getAllRecords() async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        orderBy: 'completedAt DESC',
      );

      return result
          .map((data) => PuzzleRecord(
                recordId: data['recordId'] as String,
                puzzleId: data['puzzleId'] as String,
                difficulty: Difficulty.values.firstWhere(
                  (e) => e.name == data['difficulty'],
                ),
                completedAt: DateTime.parse(data['completedAt'] as String),
                elapsedSeconds: data['elapsedSeconds'] as int,
                hintCount: data['hintCount'] as int,
              ))
          .toList();
    } catch (e) {
      developer.log('퍼즐 기록 조회 실패: $e', name: 'PuzzleRecordRepository');
      return [];
    }
  }

  @override
  Future<List<PuzzleRecord>> getRecordsByDifficulty(
      Difficulty difficulty) async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        where: 'difficulty = ?',
        whereArgs: [difficulty.name],
        orderBy: 'completedAt DESC',
      );

      return result
          .map((data) => PuzzleRecord(
                recordId: data['recordId'] as String,
                puzzleId: data['puzzleId'] as String,
                difficulty: Difficulty.values.firstWhere(
                  (e) => e.name == data['difficulty'],
                ),
                completedAt: DateTime.parse(data['completedAt'] as String),
                elapsedSeconds: data['elapsedSeconds'] as int,
                hintCount: data['hintCount'] as int,
              ))
          .toList();
    } catch (e) {
      developer.log('난이도별 퍼즐 기록 조회 실패: $e', name: 'PuzzleRecordRepository');
      return [];
    }
  }

  @override
  Future<PuzzleRecord?> getBestRecord(String puzzleId) async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        where: 'puzzleId = ?',
        whereArgs: [puzzleId],
        orderBy: 'elapsedSeconds ASC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        final data = result.first;
        return PuzzleRecord(
          recordId: data['recordId'] as String,
          puzzleId: data['puzzleId'] as String,
          difficulty: Difficulty.values.firstWhere(
            (e) => e.name == data['difficulty'],
          ),
          completedAt: DateTime.parse(data['completedAt'] as String),
          elapsedSeconds: data['elapsedSeconds'] as int,
          hintCount: data['hintCount'] as int,
        );
      }
      return null;
    } catch (e) {
      developer.log('최고 기록 조회 실패: $e', name: 'PuzzleRecordRepository');
      return null;
    }
  }

  @override
  Future<void> savePuzzleRecord(PuzzleRecord record) async {
    try {
      await _databaseService.insert(
        DatabaseService.tablePuzzleRecords,
        {
          'recordId': record.recordId,
          'puzzleId': record.puzzleId,
          'difficulty': record.difficulty.name,
          'completedAt': record.completedAt.toIso8601String(),
          'elapsedSeconds': record.elapsedSeconds,
          'hintCount': record.hintCount,
        },
      );
      developer.log('퍼즐 기록 저장 완료: ${record.recordId}',
          name: 'PuzzleRecordRepository');
    } catch (e) {
      developer.log('퍼즐 기록 저장 실패: $e', name: 'PuzzleRecordRepository');
      rethrow;
    }
  }

  @override
  Future<int> getCompletedPuzzlesCount() async {
    try {
      final result = await _databaseService.query(
        DatabaseService.tablePuzzleRecords,
        columns: ['COUNT(*) as count'],
      );
      return result.first['count'] as int;
    } catch (e) {
      developer.log('완료한 퍼즐 수 조회 실패: $e', name: 'PuzzleRecordRepository');
      return 0;
    }
  }

  @override
  Future<int> getCurrentStreak() async {
    // TODO: 일일 챌린지 연속 기록 로직 구현
    return 0;
  }

  @override
  Future<int> getBestStreak() async {
    // TODO: 최고 연속 기록 로직 구현
    return 0;
  }
}

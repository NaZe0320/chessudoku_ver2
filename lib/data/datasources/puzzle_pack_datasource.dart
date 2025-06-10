import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 퍼즐팩 데이터를 제공하는 DataSource
abstract class PuzzlePackDataSource {
  Future<List<PuzzlePack>> getAllPuzzlePacks();
  Future<PuzzlePack?> getPuzzlePackById(String id);
  Future<void> updatePuzzlePackProgress(String id, int completedPuzzles);
}

/// SQLite 데이터베이스를 사용하는 퍼즐팩 데이터소스
class PuzzlePackDatabaseDataSource implements PuzzlePackDataSource {
  final DatabaseService _databaseService;

  PuzzlePackDatabaseDataSource({
    DatabaseService? databaseService,
  }) : _databaseService = databaseService ?? DatabaseService();

  @override
  Future<List<PuzzlePack>> getAllPuzzlePacks() async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tablePuzzlePacks,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PuzzlePack.fromMap(map)).toList();
    } catch (e) {
      throw Exception('데이터베이스에서 퍼즐팩 조회 실패: $e');
    }
  }

  @override
  Future<PuzzlePack?> getPuzzlePackById(String id) async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tablePuzzlePacks,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return PuzzlePack.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('데이터베이스에서 퍼즐팩 상세 조회 실패: $e');
    }
  }

  @override
  Future<void> updatePuzzlePackProgress(String id, int completedPuzzles) async {
    try {
      await _databaseService.update(
        DatabaseService.tablePuzzlePacks,
        {
          'completed_puzzles': completedPuzzles,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('데이터베이스에서 퍼즐팩 진행률 업데이트 실패: $e');
    }
  }

  /// 난이도별 퍼즐팩 조회
  Future<List<PuzzlePack>> getPuzzlePacksByDifficulty(
      Difficulty difficulty) async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tablePuzzlePacks,
        where: 'difficulty = ?',
        whereArgs: [difficulty.name],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PuzzlePack.fromMap(map)).toList();
    } catch (e) {
      throw Exception('데이터베이스에서 난이도별 퍼즐팩 조회 실패: $e');
    }
  }

  /// 프리미엄 퍼즐팩 조회
  Future<List<PuzzlePack>> getPremiumPuzzlePacks() async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tablePuzzlePacks,
        where: 'is_premium = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PuzzlePack.fromMap(map)).toList();
    } catch (e) {
      throw Exception('데이터베이스에서 프리미엄 퍼즐팩 조회 실패: $e');
    }
  }

  /// 무료 퍼즐팩 조회
  Future<List<PuzzlePack>> getFreePuzzlePacks() async {
    try {
      final maps = await _databaseService.query(
        DatabaseService.tablePuzzlePacks,
        where: 'is_premium = ?',
        whereArgs: [0],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => PuzzlePack.fromMap(map)).toList();
    } catch (e) {
      throw Exception('데이터베이스에서 무료 퍼즐팩 조회 실패: $e');
    }
  }

  /// 퍼즐팩 추가
  Future<void> insertPuzzlePack(PuzzlePack puzzlePack) async {
    try {
      await _databaseService.insert(
        DatabaseService.tablePuzzlePacks,
        puzzlePack.toMap(),
      );
    } catch (e) {
      throw Exception('데이터베이스에서 퍼즐팩 추가 실패: $e');
    }
  }

  /// 퍼즐팩 삭제
  Future<void> deletePuzzlePack(String id) async {
    try {
      await _databaseService.delete(
        DatabaseService.tablePuzzlePacks,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('데이터베이스에서 퍼즐팩 삭제 실패: $e');
    }
  }

  /// 모든 퍼즐팩 데이터 삭제 및 Mock 데이터 재삽입
  Future<void> resetWithMockData() async {
    try {
      await _databaseService.resetPuzzlePacksWithMockData();
    } catch (e) {
      throw Exception('데이터베이스 퍼즐팩 리셋 실패: $e');
    }
  }
}

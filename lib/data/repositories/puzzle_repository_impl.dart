import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/data/services/test_service.dart';
import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:flutter/foundation.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  final DatabaseService _databaseService;
  final TestService _testService;

  PuzzleRepositoryImpl({
    required DatabaseService databaseService,
    required TestService testService,
  })  : _databaseService = databaseService,
        _testService = testService;

  @override
  Future<List<PuzzlePack>> getPuzzlePacks() async {
    final maps = await _databaseService.query(DatabaseService.tablePuzzlePacks);
    if (maps.isEmpty) {
      return [];
    }
    return maps.map((map) => PuzzlePack.fromMap(map)).toList();
  }

  @override
  Future<void> syncPuzzles(int version) async {
    debugPrint('[PuzzleRepository] 퍼즐 동기화 시작 (서버 버전: $version)');
    try {
      // 1. Fetch new puzzle data from the server (mock service)
      final puzzleData = await _testService.getPuzzleDataByVersion(version);

      final packsData = puzzleData['packs'] as List<dynamic>;

      // 2. Save data to local DB
      // Use a transaction to ensure all or nothing is saved.
      final db = await _databaseService.database;
      await db.transaction((txn) async {
        // Clear existing puzzle data
        await txn.delete(DatabaseService.tablePuzzlePacks);
        debugPrint('[PuzzleRepository] 기존 퍼즐 데이터 삭제 완료');

        // Insert new puzzle packs
        for (final packMap in packsData) {
          await txn.insert(DatabaseService.tablePuzzlePacks, packMap);
        }
        debugPrint('[PuzzleRepository] ${packsData.length}개의 퍼즐 팩 저장 완료');
      });

      debugPrint('[PuzzleRepository] 퍼즐 동기화 완료');
    } catch (e) {
      debugPrint('[PuzzleRepository] 퍼즐 동기화 중 오류 발생: $e');
      rethrow;
    }
  }
}

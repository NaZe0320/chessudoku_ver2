import 'package:chessudoku/data/datasources/puzzle_pack_datasource.dart';
import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/repositories/puzzle_pack_repository.dart';

/// PuzzlePackRepository 인터페이스의 구현체
class PuzzlePackRepositoryImpl implements PuzzlePackRepository {
  final PuzzlePackDataSource _localDataSource;
  final PuzzlePackDatabaseDataSource? _databaseDataSource;

  const PuzzlePackRepositoryImpl({
    required PuzzlePackDataSource localDataSource,
    PuzzlePackDatabaseDataSource? databaseDataSource,
  })  : _localDataSource = localDataSource,
        _databaseDataSource = databaseDataSource;

  @override
  Future<List<PuzzlePack>> getAllPuzzlePacks() async {
    try {
      // 데이터베이스 데이터소스를 우선적으로 사용
      if (_databaseDataSource != null) {
        return await _databaseDataSource.getAllPuzzlePacks();
      }
      return await _localDataSource.getAllPuzzlePacks();
    } catch (e) {
      print('퍼즐팩 전체 조회 실패: $e');
      // 데이터베이스 실패 시 fallback으로 로컬 데이터소스 사용
      try {
        return await _localDataSource.getAllPuzzlePacks();
      } catch (fallbackError) {
        print('Fallback 데이터소스도 실패: $fallbackError');
        return [];
      }
    }
  }

  @override
  Future<List<PuzzlePack>> getPuzzlePacksByDifficulty(
      Difficulty difficulty) async {
    try {
      final allPacks = await _localDataSource.getAllPuzzlePacks();
      return allPacks.where((pack) => pack.difficulty == difficulty).toList();
    } catch (e) {
      print('난이도별 퍼즐팩 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<List<PuzzlePack>> getPuzzlePacksByType(String type) async {
    try {
      final allPacks = await _localDataSource.getAllPuzzlePacks();
      return allPacks.where((pack) => pack.type.contains(type)).toList();
    } catch (e) {
      print('타입별 퍼즐팩 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<List<PuzzlePack>> getRecommendedPuzzlePacks() async {
    try {
      final allPacks = await _localDataSource.getAllPuzzlePacks();
      // 추천 로직: 완료율이 낮고 무료인 팩들 우선
      final freePacks = allPacks.where((pack) => !pack.isPremium).toList();
      freePacks.sort((a, b) => a.completionRate.compareTo(b.completionRate));
      return freePacks.take(3).toList();
    } catch (e) {
      print('추천 퍼즐팩 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<List<PuzzlePack>> getPremiumPuzzlePacks() async {
    try {
      final allPacks = await _localDataSource.getAllPuzzlePacks();
      return allPacks.where((pack) => pack.isPremium).toList();
    } catch (e) {
      print('프리미엄 퍼즐팩 조회 실패: $e');
      return [];
    }
  }

  @override
  Future<PuzzlePack?> getPuzzlePackById(String id) async {
    try {
      return await _localDataSource.getPuzzlePackById(id);
    } catch (e) {
      print('퍼즐팩 상세 조회 실패: $e');
      return null;
    }
  }

  @override
  Future<void> updatePuzzlePackProgress(String id, int completedPuzzles) async {
    try {
      await _localDataSource.updatePuzzlePackProgress(id, completedPuzzles);
    } catch (e) {
      print('퍼즐팩 진행률 업데이트 실패: $e');
      throw Exception('진행률 업데이트에 실패했습니다: $e');
    }
  }
}

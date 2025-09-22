import 'dart:convert';
import 'dart:developer' as developer;
import 'package:chessudoku/application/states/game_state.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/entities/saved_game_data.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';

/// 게임 저장/로드를 위한 Repository 구현체
/// 통합된 단일 저장 방식
class GameSaveRepositoryImpl implements GameSaveRepository {
  final CacheService _cacheService;

  // 통합된 단일 저장 키
  static const String _currentGameKey = 'current_game';

  GameSaveRepositoryImpl(this._cacheService);

  @override
  Future<bool> saveCurrentGame(
      GameState gameState, Difficulty difficulty) async {
    try {
      if (gameState.currentBoard == null) {
        return false;
      }

      final savedGameData = SavedGameData(
        board: gameState.currentBoard!,
        elapsedSeconds: gameState.elapsedSeconds,
        history: gameState.history,
        redoHistory: gameState.redoHistory,
        difficulty: difficulty,
        savedAt: DateTime.now(),
        checkpoints: gameState.checkpoints,
      );

      final jsonString = jsonEncode(savedGameData.toJson());
      final success = await _cacheService.setString(_currentGameKey, jsonString);

      if (!success) {
        developer.log('게임 저장 실패', name: 'GameSaveRepository');
      }

      return success;
    } catch (e) {
      developer.log('게임 저장 중 오류 발생: $e', name: 'GameSaveRepository');
      return false;
    }
  }

  @override
  SavedGameData? loadCurrentGame() {
    try {
      final jsonString = _cacheService.getString(_currentGameKey);
      if (jsonString == null) {
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return SavedGameData.fromJson(jsonMap);
    } catch (e) {
      developer.log('게임 로드 중 오류 발생: $e', name: 'GameSaveRepository');
      return null;
    }
  }

  @override
  Future<bool> clearCurrentGame() async {
    try {
      // 통합된 저장 키 삭제
      await _cacheService.remove(_currentGameKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasSavedGame() async {
    try {
      return _cacheService.containsKey(_currentGameKey);
    } catch (e) {
      developer.log('hasSavedGame 오류: $e', name: 'GameSaveRepository');
      return false;
    }
  }

}

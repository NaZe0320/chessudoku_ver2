import 'dart:convert';
import 'dart:developer' as developer;
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/states/game_state.dart';
import 'package:chessudoku/data/models/saved_game_data.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 게임 저장/로드를 위한 Repository 구현체
class GameSaveRepositoryImpl implements GameSaveRepository {
  final CacheService _cacheService;

  static const String _savedGameKey = 'saved_game_data';
  static const String _difficultyKey = 'saved_game_difficulty';
  static const String _timestampKey = 'saved_game_timestamp';

  GameSaveRepositoryImpl(this._cacheService);

  @override
  Future<bool> saveCurrentGame(
      GameState gameState, Difficulty difficulty) async {
    try {
      if (gameState.currentBoard == null) {
        developer.log('GameBoard가 null이므로 저장하지 않습니다.',
            name: 'GameSaveRepository');
        return false;
      }

      developer.log('게임 저장 시작 - 난이도: $difficulty', name: 'GameSaveRepository');
      developer.log('경과 시간: ${gameState.elapsedSeconds}초',
          name: 'GameSaveRepository');
      developer.log('히스토리 개수: ${gameState.history.length}',
          name: 'GameSaveRepository');

      final savedGameData = SavedGameData(
        board: gameState.currentBoard!,
        elapsedSeconds: gameState.elapsedSeconds,
        history: gameState.history,
        redoHistory: gameState.redoHistory,
        difficulty: difficulty,
        savedAt: DateTime.now(),
      );

      // JSON으로 직렬화
      final jsonString = jsonEncode(savedGameData.toJson());
      developer.log('JSON 직렬화 완료 - 길이: ${jsonString.length}',
          name: 'GameSaveRepository');

      // 저장
      final success = await _cacheService.setString(_savedGameKey, jsonString);

      if (success) {
        // 난이도와 타임스탬프도 별도 저장
        await _cacheService.setString(_difficultyKey, difficulty.name);
        await _cacheService.setInt(
            _timestampKey, DateTime.now().millisecondsSinceEpoch);
        developer.log('게임 저장 성공', name: 'GameSaveRepository');
      } else {
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
      developer.log('저장된 게임 로드 시작', name: 'GameSaveRepository');

      final jsonString = _cacheService.getString(_savedGameKey);
      if (jsonString == null) {
        developer.log('저장된 게임 데이터가 없습니다.', name: 'GameSaveRepository');
        return null;
      }

      developer.log('JSON 문자열 길이: ${jsonString.length}',
          name: 'GameSaveRepository');

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final savedGameData = SavedGameData.fromJson(jsonMap);

      developer.log('게임 로드 성공', name: 'GameSaveRepository');
      developer.log('로드된 경과 시간: ${savedGameData.elapsedSeconds}초',
          name: 'GameSaveRepository');
      developer.log('로드된 난이도: ${savedGameData.difficulty}',
          name: 'GameSaveRepository');

      return savedGameData;
    } catch (e) {
      developer.log('게임 로드 중 오류 발생: $e', name: 'GameSaveRepository');
      return null;
    }
  }

  @override
  Future<bool> clearCurrentGame() async {
    try {
      await _cacheService.remove(_savedGameKey);
      await _cacheService.remove(_difficultyKey);
      await _cacheService.remove(_timestampKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasSavedGame() async {
    developer.log('hasSavedGame 호출', name: 'GameSaveRepository');
    try {
      final result = _cacheService.containsKey(_savedGameKey);
      developer.log('hasSavedGame 결과: $result', name: 'GameSaveRepository');
      return result;
    } catch (e) {
      developer.log('hasSavedGame 오류: $e', name: 'GameSaveRepository');
      return false;
    }
  }

  @override
  Future<String?> getSavedGameInfo() async {
    developer.log('getSavedGameInfo 호출', name: 'GameSaveRepository');
    try {
      final savedGame = loadCurrentGame();
      if (savedGame == null) {
        developer.log('저장된 게임이 없음', name: 'GameSaveRepository');
        return null;
      }

      // 경과 시간을 분:초 형식으로 변환
      final minutes = savedGame.elapsedSeconds ~/ 60;
      final seconds = savedGame.elapsedSeconds % 60;
      final timeString =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      // 난이도 한글명
      String difficultyText;
      switch (savedGame.difficulty) {
        case Difficulty.easy:
          difficultyText = '쉬움';
          break;
        case Difficulty.medium:
          difficultyText = '보통';
          break;
        case Difficulty.hard:
          difficultyText = '어려움';
          break;
        case Difficulty.expert:
          difficultyText = '전문가';
          break;
      }

      final result = '$difficultyText 난이도 • $timeString';
      developer.log('getSavedGameInfo 결과: $result', name: 'GameSaveRepository');
      return result;
    } catch (e) {
      developer.log('getSavedGameInfo 오류: $e', name: 'GameSaveRepository');
      return null;
    }
  }

  @override
  Future<int> getCompletedPuzzlesCount() async {
    // TODO: 완료한 퍼즐 수 가져오기 구현
    return 0;
  }

  @override
  Future<int> getCurrentStreak() async {
    // TODO: 현재 연속 기록 가져오기 구현
    return 0;
  }
}

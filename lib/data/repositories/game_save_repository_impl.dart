import 'dart:convert';
import 'dart:developer' as developer;
import 'package:chessudoku/application/states/game_state.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/entities/saved_game_data.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';

/// 게임 저장/로드를 위한 Repository 구현체
/// 임시 저장, SQL 사용으로 변경경
class GameSaveRepositoryImpl implements GameSaveRepository {
  final CacheService _cacheService;

  // 기존 키 (하위 호환성 유지)
  static const String _savedGameKey = 'saved_game_data';
  static const String _difficultyKey = 'saved_game_difficulty';
  static const String _timestampKey = 'saved_game_timestamp';

  // 새로운 난이도별 저장 키
  static const String _lastPlayedTypeKey = 'last_played_type';

  // 난이도별 저장 키 생성 함수
  String _getSavedGameKeyByDifficulty(Difficulty difficulty) {
    return 'saved_game_${difficulty.name}';
  }

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
        checkpoints: gameState.checkpoints,
      );

      // JSON으로 직렬화
      final jsonString = jsonEncode(savedGameData.toJson());
      developer.log('JSON 직렬화 완료 - 길이: ${jsonString.length}',
          name: 'GameSaveRepository');

      // 난이도별 저장 키 사용
      final difficultyKey = _getSavedGameKeyByDifficulty(difficulty);

      // 저장
      final success = await _cacheService.setString(difficultyKey, jsonString);

      if (success) {
        // 가장 최근 플레이한 게임 타입 저장
        await _cacheService.setString(_lastPlayedTypeKey, 'difficulty');
        await _cacheService.setString(_difficultyKey, difficulty.name);
        await _cacheService.setInt(
            _timestampKey, DateTime.now().millisecondsSinceEpoch);
        developer.log('게임 저장 성공 - 키: $difficultyKey',
            name: 'GameSaveRepository');
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

      // 가장 최근 플레이한 게임 타입 확인
      final lastPlayedType = _cacheService.getString(_lastPlayedTypeKey);
      if (lastPlayedType == 'difficulty') {
        final difficultyName = _cacheService.getString(_difficultyKey);
        if (difficultyName != null) {
          final difficulty = Difficulty.values.firstWhere(
            (e) => e.name == difficultyName,
            orElse: () => Difficulty.easy,
          );
          return getSavedGameByDifficulty(difficulty);
        }
      }

      // 기존 방식으로 로드 (하위 호환성)
      final jsonString = _cacheService.getString(_savedGameKey);
      if (jsonString == null) {
        developer.log('저장된 게임 데이터가 없습니다.', name: 'GameSaveRepository');
        return null;
      }

      developer.log('JSON 문자열 길이: ${jsonString.length}',
          name: 'GameSaveRepository');

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      developer.log('JSON 파싱 완료: ${jsonMap.keys}', name: 'GameSaveRepository');

      final savedGameData = SavedGameData.fromJson(jsonMap);

      developer.log('게임 로드 성공', name: 'GameSaveRepository');
      developer.log('로드된 경과 시간: ${savedGameData.elapsedSeconds}초',
          name: 'GameSaveRepository');
      developer.log('로드된 난이도: ${savedGameData.difficulty}',
          name: 'GameSaveRepository');
      developer.log('로드된 보드 셀 수: ${savedGameData.board.board.cells.length}',
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
      // 기존 저장 키들 삭제
      await _cacheService.remove(_savedGameKey);
      await _cacheService.remove(_difficultyKey);
      await _cacheService.remove(_timestampKey);
      await _cacheService.remove(_lastPlayedTypeKey);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 특정 난이도의 저장된 게임 삭제
  @override
  Future<bool> clearGameByDifficulty(Difficulty difficulty) async {
    try {
      final difficultyKey = _getSavedGameKeyByDifficulty(difficulty);
      await _cacheService.remove(difficultyKey);

      // 현재 삭제한 난이도가 마지막 플레이한 게임인 경우 메타데이터도 삭제
      final lastPlayedType = _cacheService.getString(_lastPlayedTypeKey);
      final lastDifficultyName = _cacheService.getString(_difficultyKey);

      if (lastPlayedType == 'difficulty' &&
          lastDifficultyName == difficulty.name) {
        await _cacheService.remove(_difficultyKey);
        await _cacheService.remove(_timestampKey);
        await _cacheService.remove(_lastPlayedTypeKey);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasSavedGame() async {
    developer.log('hasSavedGame 호출', name: 'GameSaveRepository');
    try {
      // 가장 최근 플레이한 게임이 있는지 확인
      final lastPlayedType = _cacheService.getString(_lastPlayedTypeKey);
      if (lastPlayedType == 'difficulty') {
        final difficultyName = _cacheService.getString(_difficultyKey);
        if (difficultyName != null) {
          final difficulty = Difficulty.values.firstWhere(
            (e) => e.name == difficultyName,
            orElse: () => Difficulty.easy,
          );
          return hasSavedGameByDifficulty(difficulty);
        }
      }

      // 기존 방식으로 확인 (하위 호환성)
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
      final savedGame = getLatestPlayedGame();
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

  // 새로운 난이도별 저장 메서드들
  @override
  Future<bool> saveGameByDifficulty(
      SavedGameData game, Difficulty difficulty) async {
    try {
      developer.log('난이도별 게임 저장 시작 - 난이도: $difficulty',
          name: 'GameSaveRepository');

      final jsonString = jsonEncode(game.toJson());
      final difficultyKey = _getSavedGameKeyByDifficulty(difficulty);

      final success = await _cacheService.setString(difficultyKey, jsonString);

      if (success) {
        // 가장 최근 플레이한 게임 타입 저장
        await _cacheService.setString(_lastPlayedTypeKey, 'difficulty');
        await _cacheService.setString(_difficultyKey, difficulty.name);
        await _cacheService.setInt(
            _timestampKey, DateTime.now().millisecondsSinceEpoch);
        developer.log('난이도별 게임 저장 성공 - 키: $difficultyKey',
            name: 'GameSaveRepository');
      } else {
        developer.log('난이도별 게임 저장 실패', name: 'GameSaveRepository');
      }

      return success;
    } catch (e) {
      developer.log('난이도별 게임 저장 중 오류 발생: $e', name: 'GameSaveRepository');
      return false;
    }
  }

  @override
  SavedGameData? getSavedGameByDifficulty(Difficulty difficulty) {
    try {
      developer.log('난이도별 게임 로드 시작 - 난이도: $difficulty',
          name: 'GameSaveRepository');

      final difficultyKey = _getSavedGameKeyByDifficulty(difficulty);
      final jsonString = _cacheService.getString(difficultyKey);

      if (jsonString == null) {
        developer.log('해당 난이도의 저장된 게임이 없습니다.', name: 'GameSaveRepository');
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final savedGameData = SavedGameData.fromJson(jsonMap);

      developer.log('난이도별 게임 로드 성공 - 난이도: $difficulty',
          name: 'GameSaveRepository');
      return savedGameData;
    } catch (e) {
      developer.log('난이도별 게임 로드 중 오류 발생: $e', name: 'GameSaveRepository');
      return null;
    }
  }

  @override
  SavedGameData? getLatestPlayedGame() {
    try {
      developer.log('가장 최근 플레이한 게임 조회 시작', name: 'GameSaveRepository');

      final lastPlayedType = _cacheService.getString(_lastPlayedTypeKey);
      if (lastPlayedType == 'difficulty') {
        final difficultyName = _cacheService.getString(_difficultyKey);
        if (difficultyName != null) {
          final difficulty = Difficulty.values.firstWhere(
            (e) => e.name == difficultyName,
            orElse: () => Difficulty.easy,
          );
          return getSavedGameByDifficulty(difficulty);
        }
      }

      // 기존 방식으로 조회 (하위 호환성)
      return loadCurrentGame();
    } catch (e) {
      developer.log('가장 최근 플레이한 게임 조회 중 오류 발생: $e', name: 'GameSaveRepository');
      return null;
    }
  }

  @override
  String? getLastPlayedType() {
    return _cacheService.getString(_lastPlayedTypeKey);
  }

  @override
  Future<bool> hasSavedGameByDifficulty(Difficulty difficulty) async {
    try {
      final difficultyKey = _getSavedGameKeyByDifficulty(difficulty);
      return _cacheService.containsKey(difficultyKey);
    } catch (e) {
      developer.log('난이도별 저장된 게임 확인 중 오류 발생: $e', name: 'GameSaveRepository');
      return false;
    }
  }

  @override
  Future<bool> saveLastPlayedType(String type) async {
    try {
      return await _cacheService.setString(_lastPlayedTypeKey, type);
    } catch (e) {
      developer.log('가장 최근 플레이한 게임 타입 저장 중 오류 발생: $e',
          name: 'GameSaveRepository');
      return false;
    }
  }
}

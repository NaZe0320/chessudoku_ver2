import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/application/intents/main_intent.dart';
import 'package:chessudoku/application/states/main_state.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/domain/entities/saved_game_data.dart';

import 'dart:developer' as developer;

class MainNotifier extends BaseNotifier<MainIntent, MainState> {
  final GameSaveRepository _gameSaveRepository;

  MainNotifier(this._gameSaveRepository) : super(const MainState());

  @override
  void onIntent(MainIntent intent) {
    switch (intent) {
      case CheckSavedGameIntent():
        _handleCheckSavedGame();
      case ClearSavedGameIntent():
        _handleClearSavedGame();
      case ContinueSavedGameIntent():
        _handleContinueSavedGame(intent.difficulty);
      case GetGameStartInfoIntent():
        _handleGetGameStartInfo();
    }
  }

  Future<void> _handleCheckSavedGame() async {
    developer.log('저장된 게임 확인 시작', name: 'MainNotifier');

    try {
      final hasSavedGame = await _gameSaveRepository.hasSavedGame();
      developer.log('저장된 게임 존재 여부: $hasSavedGame', name: 'MainNotifier');

      SavedGameData? savedGameData;
      if (hasSavedGame) {
        savedGameData = _gameSaveRepository.loadCurrentGame();
        developer.log('저장된 게임 데이터 로드: ${savedGameData?.difficulty}', name: 'MainNotifier');
      }

      state = state.copyWith(
        hasSavedGame: hasSavedGame,
        savedGameData: savedGameData,
        isLoading: false,
      );
      developer.log('상태 업데이트 완료', name: 'MainNotifier');
    } catch (e) {
      developer.log('저장된 게임 확인 중 오류: $e', name: 'MainNotifier');
      state = state.copyWith(
        hasSavedGame: false,
        savedGameData: null,
        isLoading: false,
      );
    }
  }

  Future<void> _handleClearSavedGame() async {
    try {
      await _gameSaveRepository.clearCurrentGame();
      state = state.copyWith(
        hasSavedGame: false,
        savedGameData: null,
        savedGameBoard: null,
      );
    } catch (e) {
      // 에러 처리
    }
  }

  // 저장된 게임 이어서 하기 (통합된 방식)
  Future<void> _handleContinueSavedGame(
      [Difficulty? specificDifficulty]) async {
    developer.log('저장된 게임 이어서 하기 시작 (난이도: ${specificDifficulty ?? '자동'})',
        name: 'MainNotifier');
    try {
      SavedGameData? savedGameData;

      // 통합 시스템에서는 현재 저장된 게임만 로드
      savedGameData = _gameSaveRepository.loadCurrentGame();
      developer.log('저장된 게임 로드 시도', name: 'MainNotifier');

      if (savedGameData != null) {
        developer.log('저장된 게임 데이터 로드 성공', name: 'MainNotifier');
        developer.log('로드된 난이도: ${savedGameData.difficulty}',
            name: 'MainNotifier');
        developer.log('로드된 경과 시간: ${savedGameData.elapsedSeconds}초',
            name: 'MainNotifier');

        state = state.copyWith(
          savedGameBoard: savedGameData.board,
          selectedDifficulty: savedGameData.difficulty,
          shouldStartNewGame: false,
          shouldContinueGame: true,
        );
      } else {
        developer.log('저장된 게임 데이터가 없습니다.', name: 'MainNotifier');
        // 저장된 게임이 없는 경우
        state = state.copyWith(
          savedGameBoard: null,
          shouldStartNewGame: false,
          shouldContinueGame: false,
        );
      }
    } catch (e) {
      developer.log('저장된 게임 이어서 하기 중 오류: $e', name: 'MainNotifier');
      // 에러 처리 - 저장된 게임이 없거나 로드 실패
      state = state.copyWith(
        savedGameBoard: null,
        shouldStartNewGame: false,
        shouldContinueGame: false,
      );
    }
  }

  // 게임 시작 정보 초기화
  void _handleGetGameStartInfo() {
    state = state.copyWith(
      shouldStartNewGame: false,
      shouldContinueGame: false,
    );
  }

}

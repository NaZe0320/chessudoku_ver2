import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/main_intent.dart';
import 'package:chessudoku/domain/states/main_state.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/data/models/saved_game_data.dart';
import 'dart:developer' as developer;

class MainNotifier extends BaseNotifier<MainIntent, MainState> {
  final GameSaveRepository _gameSaveRepository;

  MainNotifier(this._gameSaveRepository) : super(const MainState());

  @override
  void onIntent(MainIntent intent) {
    switch (intent) {
      case CheckSavedGameIntent():
        _handleCheckSavedGame();
      case LoadSavedGameIntent():
        _handleLoadSavedGame();
      case ClearSavedGameIntent():
        _handleClearSavedGame();
      case LoadStatsIntent():
        _handleLoadStats();
      case StartNewGameIntent():
        _handleStartNewGame(intent.difficulty);
      case ContinueSavedGameIntent():
        _handleContinueSavedGame();
      case GetGameStartInfoIntent():
        _handleGetGameStartInfo();
    }
  }

  Future<void> _handleCheckSavedGame() async {
    developer.log('저장된 게임 확인 시작', name: 'MainNotifier');

    try {
      developer.log('상태 업데이트 없이 로직만 실행', name: 'MainNotifier');

      developer.log('hasSavedGame 호출 전', name: 'MainNotifier');
      final hasSavedGame = await _gameSaveRepository.hasSavedGame();
      developer.log('저장된 게임 존재 여부: $hasSavedGame', name: 'MainNotifier');

      String? savedGameInfo;
      if (hasSavedGame) {
        developer.log('getSavedGameInfo 호출 전', name: 'MainNotifier');
        savedGameInfo = await _gameSaveRepository.getSavedGameInfo();
        developer.log('저장된 게임 정보: $savedGameInfo', name: 'MainNotifier');
      } else {
        developer.log('저장된 게임이 없으므로 정보 가져오기 생략', name: 'MainNotifier');
      }

      developer.log(
          '로직 실행 완료 - hasSavedGame: $hasSavedGame, savedGameInfo: $savedGameInfo',
          name: 'MainNotifier');

      // 상태 업데이트 다시 활성화
      developer.log('상태 업데이트 시작', name: 'MainNotifier');
      state = state.copyWith(
        hasSavedGame: hasSavedGame,
        savedGameInfo: savedGameInfo,
        isLoading: false,
      );
      developer.log('상태 업데이트 완료', name: 'MainNotifier');
    } catch (e) {
      developer.log('저장된 게임 확인 중 오류: $e', name: 'MainNotifier');
      // 오류 시에도 상태 업데이트
      try {
        state = state.copyWith(
          hasSavedGame: false,
          savedGameInfo: null,
          isLoading: false,
        );
      } catch (stateError) {
        developer.log('오류 상태 업데이트 중 오류: $stateError', name: 'MainNotifier');
      }
    }
  }

  Future<void> _handleLoadSavedGame() async {
    // TODO: 저장된 게임 로드 구현
  }

  Future<void> _handleClearSavedGame() async {
    try {
      await _gameSaveRepository.clearCurrentGame();
      state = state.copyWith(
        hasSavedGame: false,
        savedGameInfo: null,
        savedGameBoard: null,
      );
    } catch (e) {
      // 에러 처리
    }
  }

  Future<void> _handleLoadStats() async {
    try {
      final completedPuzzles =
          await _gameSaveRepository.getCompletedPuzzlesCount();
      final currentStreak = await _gameSaveRepository.getCurrentStreak();

      state = state.copyWith(
        completedPuzzles: completedPuzzles,
        currentStreak: currentStreak,
      );
    } catch (e) {
      // 에러 처리
    }
  }

  // 새 게임 시작 처리
  void _handleStartNewGame(Difficulty difficulty) {
    // 테스트용 보드 생성 (실제로는 난이도에 따라 다른 보드 생성)
    final gameBoard = _createTestBoard(difficulty);

    state = state.copyWith(
      selectedDifficulty: difficulty,
      savedGameBoard: gameBoard,
      shouldStartNewGame: true,
      shouldContinueGame: false,
    );
  }

  // 저장된 게임 이어서 하기
  Future<void> _handleContinueSavedGame() async {
    developer.log('저장된 게임 이어서 하기 시작', name: 'MainNotifier');
    try {
      // 저장된 게임 데이터 로드
      final savedGameData = _gameSaveRepository.loadCurrentGame();

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

  // 테스트용 보드 생성 (하나만 입력해도 완료 가능한 간단한 퍼즐)
  GameBoard _createTestBoard(Difficulty difficulty) {
    developer.log('테스트 보드 생성 시작', name: 'MainNotifier');

    // 완성된 스도쿠 답안 (대부분이 이미 채워진 상태)
    final solutionPuzzle = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [4, 5, 6, 7, 8, 9, 1, 2, 3],
      [7, 8, 9, 1, 2, 3, 4, 5, 6],
      [2, 3, 4, 5, 6, 7, 8, 9, 1],
      [5, 6, 7, 8, 9, 1, 2, 3, 4],
      [8, 9, 1, 2, 3, 4, 5, 6, 7],
      [3, 4, 5, 6, 7, 8, 9, 1, 2],
      [6, 7, 8, 9, 1, 2, 3, 4, 5],
      [9, 1, 2, 3, 4, 5, 6, 7, 8],
    ];

    // 빈칸이 하나만 있는 퍼즐 (하나만 입력하면 완료)
    final puzzleWithBlanks = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [4, 5, 6, 7, 8, 9, 1, 2, 3],
      [7, 8, 9, 1, 2, 3, 4, 5, 6],
      [2, 3, 4, 5, 6, 7, 8, 9, 1],
      [5, 6, 7, 8, null, 1, 2, 3, 4], // (4,4) 위치만 빈칸 (체스 기물 위치)
      [8, 9, 1, 2, 3, 4, 5, 6, 7],
      [3, 4, 5, 6, 7, 8, 9, 1, 2],
      [6, 7, 8, 9, 1, 2, 3, 4, 5],
      [9, 1, 2, 3, 4, 5, 6, 7, 8],
    ];

    // 체스 기물 배치 (빈칸 위치에 queen 배치)
    final chessPieces = <Position, ChessPiece>{
      const Position(row: 4, col: 4): ChessPiece.queen, // 빈칸 위치에 queen
    };

    developer.log('체스 기물 개수: ${chessPieces.length}', name: 'MainNotifier');
    for (final entry in chessPieces.entries) {
      developer.log('체스 기물: ${entry.key} -> ${entry.value}',
          name: 'MainNotifier');
    }

    // 체스 기물을 포함한 보드 생성
    final puzzleBoard = SudokuBoard.fromPuzzleWithChess(
      puzzle: puzzleWithBlanks,
      chessPieces: chessPieces,
    );

    developer.log('퍼즐 보드 생성 완료 - 셀 수: ${puzzleBoard.cells.length}',
        name: 'MainNotifier');

    final solutionBoard = SudokuBoard.fromPuzzle(solutionPuzzle);
    developer.log('솔루션 보드 생성 완료 - 셀 수: ${solutionBoard.cells.length}',
        name: 'MainNotifier');

    final gameBoard = GameBoard(
      board: puzzleBoard,
      solutionBoard: solutionBoard,
      difficulty: difficulty,
      puzzleId: 'test_puzzle_simple',
    );

    developer.log('게임 보드 생성 완료 - 최종 셀 수: ${gameBoard.board.cells.length}',
        name: 'MainNotifier');
    return gameBoard;
  }
}

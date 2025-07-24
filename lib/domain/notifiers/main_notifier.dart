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

  // 테스트용 보드 생성 (GameNotifier의 _handleInitializeTestBoard 로직을 여기로 이동)
  GameBoard _createTestBoard(Difficulty difficulty) {
    developer.log('테스트 보드 생성 시작', name: 'MainNotifier');

    // 완성된 스도쿠 답안 (체스 기물 위치는 빈 칸으로)
    final solutionPuzzle = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, null, 2, 1, 9, 5, 3, 4, 8], // (1,1) knight 위치
      [1, 9, 8, 3, null, 2, 5, 6, 7], // (2,4) bishop 위치
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, null, 3, 7, 9, 1], // (4,4) queen 위치
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, null, 7, 2, 8, 4], // (6,4) rook 위치
      [2, 8, 7, 4, 1, 9, 6, 3, 5], // (7,2) pawn 위치
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];

    // 빈칸이 있는 퍼즐 (일부 셀을 null로 설정)
    final puzzleWithBlanks = [
      [5, 3, null, 6, 7, 8, 9, null, 2],
      [6, null, 2, 1, 9, null, 3, 4, 8], // (1,1) knight 위치
      [null, 9, 8, 3, null, 2, 5, 6, null], // (2,4) bishop 위치
      [8, 5, null, 7, 6, 1, null, 2, 3],
      [4, null, 6, 8, null, 3, 7, null, 1], // (4,4) queen 위치
      [7, 1, null, 9, 2, null, 8, 5, 6],
      [null, 6, 1, 5, null, 7, 2, 8, null], // (6,4) rook 위치
      [2, 8, null, 4, 1, null, 6, 3, 5], // (7,2) pawn 위치
      [3, null, 5, 2, 8, 6, null, 7, 9],
    ];

    // 체스 기물 배치 (일부 셀에만)
    final chessPieces = <Position, ChessPiece>{
      const Position(row: 1, col: 1): ChessPiece.knight,
      const Position(row: 2, col: 4): ChessPiece.bishop,
      const Position(row: 4, col: 4): ChessPiece.queen,
      const Position(row: 6, col: 4): ChessPiece.rook,
      const Position(row: 7, col: 2): ChessPiece.pawn,
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
      puzzleId: 'test_puzzle_with_chess',
    );

    developer.log('게임 보드 생성 완료 - 최종 셀 수: ${gameBoard.board.cells.length}',
        name: 'MainNotifier');
    return gameBoard;
  }
}

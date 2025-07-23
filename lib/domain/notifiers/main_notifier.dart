import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/main_intent.dart';
import 'package:chessudoku/domain/states/main_state.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

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
    state = state.copyWith(isLoading: true);

    try {
      final hasSavedGame = await _gameSaveRepository.hasSavedGame();
      final savedGameInfo =
          hasSavedGame ? await _gameSaveRepository.getSavedGameInfo() : null;

      state = state.copyWith(
        hasSavedGame: hasSavedGame,
        savedGameInfo: savedGameInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasSavedGame: false,
        savedGameInfo: null,
        isLoading: false,
      );
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
    try {
      // 저장된 게임 보드 로드
      final savedBoard = _gameSaveRepository.loadCurrentGame();

      state = state.copyWith(
        savedGameBoard: savedBoard?.currentBoard,
        shouldStartNewGame: false,
        shouldContinueGame: true,
      );
    } catch (e) {
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

    // 체스 기물을 포함한 보드 생성
    final puzzleBoard = SudokuBoard.fromPuzzleWithChess(
      puzzle: puzzleWithBlanks,
      chessPieces: chessPieces,
    );

    final solutionBoard = SudokuBoard.fromPuzzle(solutionPuzzle);

    return GameBoard(
      board: puzzleBoard,
      solutionBoard: solutionBoard,
      difficulty: difficulty,
      puzzleId: 'test_puzzle_with_chess',
    );
  }
}

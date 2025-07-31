import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/domain/intents/game_preparation_intent.dart';
import 'package:chessudoku/domain/states/game_preparation_state.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/core/network/network_service.dart';
import 'dart:developer' as developer;

class GamePreparationNotifier
    extends BaseNotifier<GamePreparationIntent, GamePreparationState> {
  final GameSaveRepository _gameSaveRepository;
  final NetworkService _networkService;

  GamePreparationNotifier({
    required GameSaveRepository gameSaveRepository,
    NetworkService? networkService,
  })  : _gameSaveRepository = gameSaveRepository,
        _networkService = networkService ?? NetworkService(),
        super(const GamePreparationState());

  @override
  void onIntent(GamePreparationIntent intent) {
    switch (intent) {
      case StartGamePreparationIntent():
        _handleStartPreparation(intent.difficulty, intent.isNewGame);
      case CancelGamePreparationIntent():
        _handleCancelPreparation();
      case RetryGamePreparationIntent():
        _handleRetryPreparation();
    }
  }

  void _handleStartPreparation(Difficulty difficulty, bool isNewGame) async {
    state = state.copyWith(
      isPreparing: true,
      isReady: false,
      error: null,
      difficulty: difficulty,
    );

    try {
      GameBoard? gameBoard;

      if (isNewGame) {
        // 새 게임 준비 - 네트워크 상태 확인 후 퍼즐 생성
        gameBoard = await _prepareNewGame(difficulty);
      } else {
        // 이어서 하기 - 저장된 게임 로드 (네트워크 불필요)
        final savedGameData =
            _gameSaveRepository.getSavedGameByDifficulty(difficulty);
        if (savedGameData != null) {
          gameBoard = savedGameData.board;
        } else {
          throw Exception('저장된 게임을 찾을 수 없습니다.');
        }
      }

      if (gameBoard != null) {
        state = state.copyWith(
          isPreparing: false,
          isReady: true,
          preparedBoard: gameBoard,
          puzzleId: gameBoard.puzzleId,
        );
      } else {
        throw Exception('게임 보드를 생성할 수 없습니다.');
      }
    } catch (e) {
      state = state.copyWith(
        isPreparing: false,
        isReady: false,
        error: e.toString(),
      );
    }
  }

  void _handleCancelPreparation() {
    state = const GamePreparationState();
  }

  void _handleRetryPreparation() {
    final currentDifficulty = state.difficulty;
    if (currentDifficulty != null) {
      handleIntent(StartGamePreparationIntent(
        difficulty: currentDifficulty,
        isNewGame: true,
      ));
    }
  }

  Future<GameBoard?> _prepareNewGame(Difficulty difficulty) async {
    // 네트워크 상태 확인
    final isOnline = await _networkService.checkConnectivity();

    if (!isOnline) {
      throw Exception('인터넷 연결이 필요합니다. 새 퍼즐을 다운로드하려면 온라인 상태여야 합니다.');
    }

    // 퍼즐 생성 (MainNotifier의 로직 사용)
    return _createTestBoard(difficulty);
  }

  // MainNotifier의 퍼즐 생성 로직을 복사
  GameBoard _createTestBoard(Difficulty difficulty) {
    developer.log('테스트 보드 생성 시작', name: 'GamePreparationNotifier');

    // 완성된 스도쿠 답안 (대부분이 이미 채워진 상태)
    final solutionPuzzle = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [4, 5, 6, 7, 8, 9, 1, 2, 3],
      [7, 8, 9, 1, 2, 3, 4, 5, 6],
      [2, 3, 4, 5, 6, 7, 8, 9, 1],
      [5, 6, 7, 8, null, 1, 2, 3, 4],
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
      [5, 6, 7, 8, null, null, 2, 3, 4], // (4,4) 위치만 빈칸 (체스 기물 위치)
      [8, 9, 1, 2, 3, 4, 5, 6, 7],
      [3, 4, 5, 6, 7, 8, 9, 1, 2],
      [6, 7, 8, 9, 1, 2, 3, 4, 5],
      [9, 1, 2, 3, 4, 5, 6, 7, 8],
    ];

    // 체스 기물 배치 (빈칸 위치에 queen 배치)
    final chessPieces = <Position, ChessPiece>{
      const Position(row: 4, col: 4): ChessPiece.queen, // 빈칸 위치에 queen
    };

    developer.log('체스 기물 개수: ${chessPieces.length}',
        name: 'GamePreparationNotifier');
    for (final entry in chessPieces.entries) {
      developer.log('체스 기물: ${entry.key} -> ${entry.value}',
          name: 'GamePreparationNotifier');
    }

    // 체스 기물을 포함한 보드 생성
    final puzzleBoard = SudokuBoard.fromPuzzleWithChess(
      puzzle: puzzleWithBlanks,
      chessPieces: chessPieces,
    );

    developer.log('퍼즐 보드 생성 완료 - 셀 수: ${puzzleBoard.cells.length}',
        name: 'GamePreparationNotifier');

    final solutionBoard = SudokuBoard.fromPuzzle(solutionPuzzle);
    developer.log('솔루션 보드 생성 완료 - 셀 수: ${solutionBoard.cells.length}',
        name: 'GamePreparationNotifier');

    final gameBoard = GameBoard(
      board: puzzleBoard,
      solutionBoard: solutionBoard,
      difficulty: difficulty,
      puzzleId: 'test_puzzle_simple',
    );

    developer.log('게임 보드 생성 완료 - 최종 셀 수: ${gameBoard.board.cells.length}',
        name: 'GamePreparationNotifier');
    return gameBoard;
  }

  /// 준비된 게임 데이터 반환
  GameBoard? getPreparedBoard() {
    return state.preparedBoard;
  }

  /// 준비 상태 초기화
  void reset() {
    state = const GamePreparationState();
  }
}

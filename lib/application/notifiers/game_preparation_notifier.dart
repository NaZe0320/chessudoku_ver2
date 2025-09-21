import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/application/intents/game_preparation_intent.dart';
import 'package:chessudoku/application/states/game_preparation_state.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:chessudoku/core/enums/chess_piece.dart';
import 'package:chessudoku/domain/entities/game_board.dart';
import 'package:chessudoku/domain/entities/sudoku_board.dart';
import 'package:chessudoku/domain/entities/position.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;

class GamePreparationNotifier
    extends BaseNotifier<GamePreparationIntent, GamePreparationState> {
  final GameSaveRepository _gameSaveRepository;
  final PuzzleRepository _puzzleRepository;

  GamePreparationNotifier({
    required GameSaveRepository gameSaveRepository,
    required PuzzleRepository puzzleRepository,
  })  : _gameSaveRepository = gameSaveRepository,
        _puzzleRepository = puzzleRepository,
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

        // 오프라인 상태인 경우 (null 반환) 여기서 처리
        if (gameBoard == null) {
          // _prepareNewGame에서 이미 오프라인 에러 상태로 설정했으므로
          // 추가 처리 없이 종료
          return;
        }
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

      state = state.copyWith(
        isPreparing: false,
        isReady: true,
        preparedBoard: gameBoard,
        puzzleId: gameBoard.puzzleId,
      );
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
    final connectivity = Connectivity();
    final isOnline =
        await connectivity.checkConnectivity() != ConnectivityResult.none;

    if (!isOnline) {
      // 오프라인 상태를 상태로 관리 (Exception 대신)
      state = state.copyWith(
        isPreparing: false,
        isReady: false,
        error: 'OFFLINE_ERROR: 인터넷 연결이 필요합니다. 새 퍼즐을 다운로드하려면 온라인 상태여야 합니다.',
      );
      return null;
    }

    // 서버에서 랜덤 퍼즐 가져오기
    return _loadRandomPuzzleFromServer(difficulty);
  }

  /// 서버에서 랜덤 퍼즐을 가져와서 GameBoard로 변환
  Future<GameBoard?> _loadRandomPuzzleFromServer(Difficulty difficulty) async {
    try {
      developer.log('서버에서 랜덤 퍼즐 로드 시작 - $difficulty',
          name: 'GamePreparationNotifier');

      // 서버에서 랜덤 퍼즐 조회 (난이도 파라미터 없이)
      final puzzle = await _puzzleRepository.getRandomPuzzle();

      if (puzzle == null) {
        developer.log('서버에서 퍼즐을 가져올 수 없습니다 - $difficulty',
            name: 'GamePreparationNotifier');
        throw Exception('서버에서 퍼즐을 가져올 수 없습니다.');
      }

      developer.log('퍼즐 로드 완료 - ${puzzle.puzzleId}',
          name: 'GamePreparationNotifier');

      // 서버에서 가져온 체스 기물을 Position, ChessPiece 맵으로 변환
      final chessPiecesMap = <Position, ChessPiece>{};
      puzzle.chessPieces.forEach((key, value) {
        // key는 "row,col" 형식, value는 체스 기물 이름
        final parts = key.split(',');
        if (parts.length == 2) {
          final row = int.tryParse(parts[0]);
          final col = int.tryParse(parts[1]);
          if (row != null && col != null) {
            final position = Position(row: row, col: col);
            final chessPiece = ChessPiece.fromString(value);
            chessPiecesMap[position] = chessPiece;
          }
        }
      });

      developer.log('체스 기물 개수: ${chessPiecesMap.length}',
          name: 'GamePreparationNotifier');

      // 체스 기물을 포함한 보드 생성
      final puzzleBoard = SudokuBoard.fromPuzzleWithChess(
        puzzle: puzzle.puzzle,
        chessPieces: chessPiecesMap,
      );

      developer.log('퍼즐 보드 생성 완료 - 셀 수: ${puzzleBoard.cells.length}',
          name: 'GamePreparationNotifier');

      // 솔루션 보드 생성
      final solutionBoard = SudokuBoard.fromPuzzle(puzzle.solution);
      developer.log('솔루션 보드 생성 완료 - 셀 수: ${solutionBoard.cells.length}',
          name: 'GamePreparationNotifier');

      // GameBoard 생성
      final gameBoard = GameBoard(
        board: puzzleBoard,
        solutionBoard: solutionBoard,
        difficulty: puzzle.difficulty,
        puzzleId: puzzle.puzzleId,
      );

      developer.log('게임 보드 생성 완료 - 최종 셀 수: ${gameBoard.board.cells.length}',
          name: 'GamePreparationNotifier');
      return gameBoard;
    } catch (e) {
      developer.log('서버에서 퍼즐 로드 실패 - $e', name: 'GamePreparationNotifier');
      rethrow;
    }
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

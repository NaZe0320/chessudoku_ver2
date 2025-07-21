import 'dart:convert';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/checkpoint.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/repositories/game_save_repository.dart';
import 'package:chessudoku/domain/states/game_state.dart';

/// 게임 저장/로드를 위한 Repository 구현체
class GameSaveRepositoryImpl implements GameSaveRepository {
  final CacheService _cacheService;

  // 게임 저장 관련 키 상수
  static const String _currentGameKey = 'current_game';

  GameSaveRepositoryImpl(this._cacheService);

  @override
  Future<bool> saveCurrentGame(GameState gameState) async {
    try {
      final gameData = _gameStateToJson(gameState);
      return await _cacheService.setString(_currentGameKey, gameData);
    } catch (e) {
      print('게임 저장 실패: $e');
      return false;
    }
  }

  @override
  GameState? loadCurrentGame() {
    try {
      final gameData = _cacheService.getString(_currentGameKey);
      if (gameData == null) return null;

      return _jsonToGameState(gameData);
    } catch (e) {
      print('게임 로드 실패: $e');
      return null;
    }
  }

  @override
  Future<bool> clearCurrentGame() async {
    return await _cacheService.remove(_currentGameKey);
  }

  // ===== 내부 헬퍼 메서드들 =====

  /// GameState를 JSON 문자열로 변환
  String _gameStateToJson(GameState gameState) {
    final Map<String, dynamic> data = {
      'isLoading': gameState.isLoading,
      'selectedNumbers': gameState.selectedNumbers.toList(),
      'elapsedSeconds': gameState.elapsedSeconds,
      'isTimerRunning': gameState.isTimerRunning,
      'currentBoard': gameState.currentBoard != null
          ? _gameBoardToJson(gameState.currentBoard!)
          : null,
      'history':
          gameState.history.map((board) => _gameBoardToJson(board)).toList(),
      'redoHistory': gameState.redoHistory
          .map((board) => _gameBoardToJson(board))
          .toList(),
      'checkpoints': _checkpointsToJson(gameState.checkpoints),
      'canUndo': gameState.canUndo,
      'canRedo': gameState.canRedo,
      'isGameCompleted': gameState.isGameCompleted,
      'showCompletionDialog': gameState.showCompletionDialog,
    };

    return jsonEncode(data);
  }

  /// JSON 문자열을 GameState로 변환
  GameState? _jsonToGameState(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      return GameState(
        isLoading: data['isLoading'] ?? false,
        selectedNumbers: Set<int>.from(data['selectedNumbers'] ?? []),
        elapsedSeconds: data['elapsedSeconds'] ?? 0,
        isTimerRunning: data['isTimerRunning'] ?? false,
        currentBoard: data['currentBoard'] != null
            ? _jsonToGameBoard(data['currentBoard'])
            : null,
        history: (data['history'] as List?)
                ?.map((board) => _jsonToGameBoard(board))
                .where((board) => board != null)
                .cast<GameBoard>()
                .toList() ??
            [],
        redoHistory: (data['redoHistory'] as List?)
                ?.map((board) => _jsonToGameBoard(board))
                .where((board) => board != null)
                .cast<GameBoard>()
                .toList() ??
            [],
        checkpoints: _jsonToCheckpoints(data['checkpoints'] ?? {}),
        canUndo: data['canUndo'] ?? false,
        canRedo: data['canRedo'] ?? false,
        isGameCompleted: data['isGameCompleted'] ?? false,
        showCompletionDialog: data['showCompletionDialog'] ?? false,
      );
    } catch (e) {
      print('JSON을 GameState로 변환 실패: $e');
      return null;
    }
  }

  /// GameBoard를 JSON 문자열로 변환
  String _gameBoardToJson(GameBoard gameBoard) {
    final Map<String, dynamic> data = {
      'board': _sudokuBoardToJson(gameBoard.board),
      'solutionBoard': _sudokuBoardToJson(gameBoard.solutionBoard),
      'selectedCell': gameBoard.selectedCell != null
          ? {
              'row': gameBoard.selectedCell!.row,
              'col': gameBoard.selectedCell!.col
            }
          : null,
      'highlightedCells': gameBoard.highlightedCells
          .map((pos) => {'row': pos.row, 'col': pos.col})
          .toList(),
      'errorCells': gameBoard.errorCells
          .map((pos) => {'row': pos.row, 'col': pos.col})
          .toList(),
      'difficulty': gameBoard.difficulty.name,
      'puzzleId': gameBoard.puzzleId,
      'isNoteMode': gameBoard.isNoteMode,
    };

    return jsonEncode(data);
  }

  /// JSON 문자열을 GameBoard로 변환
  GameBoard? _jsonToGameBoard(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      return GameBoard(
        board: _jsonToSudokuBoard(data['board']),
        solutionBoard: _jsonToSudokuBoard(data['solutionBoard']),
        selectedCell: data['selectedCell'] != null
            ? Position(
                row: data['selectedCell']['row'],
                col: data['selectedCell']['col'])
            : null,
        highlightedCells: (data['highlightedCells'] as List)
            .map((pos) => Position(row: pos['row'], col: pos['col']))
            .toSet(),
        errorCells: (data['errorCells'] as List)
            .map((pos) => Position(row: pos['row'], col: pos['col']))
            .toSet(),
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == data['difficulty'],
          orElse: () => Difficulty.easy,
        ),
        puzzleId: data['puzzleId'],
        isNoteMode: data['isNoteMode'] ?? false,
      );
    } catch (e) {
      print('JSON을 GameBoard로 변환 실패: $e');
      return null;
    }
  }

  /// SudokuBoard를 JSON으로 변환
  Map<String, dynamic> _sudokuBoardToJson(SudokuBoard board) {
    final List<List<Map<String, dynamic>?>> cells = [];

    for (int row = 0; row < 9; row++) {
      final List<Map<String, dynamic>?> rowData = [];
      for (int col = 0; col < 9; col++) {
        final content = board.getCellContent(Position(row: row, col: col));
        if (content != null) {
          rowData.add({
            'number': content.number,
            'notes': content.notes.toList(),
            'isInitial': content.isInitial,
          });
        } else {
          rowData.add(null);
        }
      }
      cells.add(rowData);
    }

    return {'cells': cells};
  }

  /// JSON을 SudokuBoard로 변환
  SudokuBoard _jsonToSudokuBoard(Map<String, dynamic> data) {
    final List<List<int?>> puzzle = [];
    final List<List<Map<String, dynamic>?>> cells = data['cells'];

    for (int row = 0; row < 9; row++) {
      final List<int?> rowData = [];
      for (int col = 0; col < 9; col++) {
        final cellData = cells[row][col];
        rowData.add(cellData?['number']);
      }
      puzzle.add(rowData);
    }

    return SudokuBoard.fromPuzzle(puzzle);
  }

  /// Checkpoints를 JSON으로 변환
  Map<String, dynamic> _checkpointsToJson(Map<String, Checkpoint> checkpoints) {
    final Map<String, dynamic> result = {};

    checkpoints.forEach((key, checkpoint) {
      result[key] = {
        'board': _gameBoardToJson(checkpoint.board),
        'elapsedSeconds': checkpoint.elapsedSeconds,
        'createdAt': checkpoint.createdAt.toIso8601String(),
        'history':
            checkpoint.history.map((board) => _gameBoardToJson(board)).toList(),
        'redoHistory': checkpoint.redoHistory
            .map((board) => _gameBoardToJson(board))
            .toList(),
      };
    });

    return result;
  }

  /// JSON을 Checkpoints로 변환
  Map<String, Checkpoint> _jsonToCheckpoints(Map<String, dynamic> data) {
    final Map<String, Checkpoint> result = {};

    data.forEach((key, value) {
      try {
        final checkpointData = value as Map<String, dynamic>;
        result[key] = Checkpoint(
          board: _jsonToGameBoard(checkpointData['board'])!,
          elapsedSeconds: checkpointData['elapsedSeconds'],
          createdAt: DateTime.parse(checkpointData['createdAt']),
          history: (checkpointData['history'] as List)
              .map((board) => _jsonToGameBoard(board))
              .where((board) => board != null)
              .cast<GameBoard>()
              .toList(),
          redoHistory: (checkpointData['redoHistory'] as List)
              .map((board) => _jsonToGameBoard(board))
              .where((board) => board != null)
              .cast<GameBoard>()
              .toList(),
        );
      } catch (e) {
        print('Checkpoint 변환 실패: $e');
      }
    });

    return result;
  }
}

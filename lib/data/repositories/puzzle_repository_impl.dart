import 'dart:developer' as developer;
import 'dart:convert';
import 'package:chessudoku/domain/repositories/puzzle_repository.dart';
import 'package:chessudoku/data/services/firestore_service.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/data/models/position.dart';

/// 퍼즐 Repository 구현체
class PuzzleRepositoryImpl implements PuzzleRepository {
  final FirestoreService _firestoreService;
  final CacheService _cacheService;

  PuzzleRepositoryImpl({
    required FirestoreService firestoreService,
    required CacheService cacheService,
  })  : _firestoreService = firestoreService,
        _cacheService = cacheService;

  @override
  Future<GameBoard?> getPuzzleFromFirebase(Difficulty difficulty) async {
    try {
      developer.log('Firebase에서 퍼즐 가져오기 시작 - 난이도: ${difficulty.name}');

      final puzzleData =
          await _firestoreService.getPuzzleFromFirebase(difficulty);

      if (puzzleData != null) {
        final gameBoard = _convertToGameBoard(puzzleData);

        // 캐시에 저장
        await cachePuzzle(gameBoard, difficulty);

        developer.log('Firebase에서 퍼즐 가져오기 완료');
        return gameBoard;
      } else {
        developer.log('Firebase에서 퍼즐을 찾을 수 없음');
        return null;
      }
    } catch (e) {
      developer.log('Firebase에서 퍼즐 가져오기 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> cachePuzzle(GameBoard puzzle, Difficulty difficulty) async {
    try {
      final cacheKey = 'puzzle_${difficulty.name}';
      final puzzleJson = jsonEncode(_gameBoardToJson(puzzle));
      await _cacheService.setString(cacheKey, puzzleJson);
      developer.log('퍼즐 캐시 저장 완료 - 난이도: ${difficulty.name}');
    } catch (e) {
      developer.log('퍼즐 캐시 저장 실패: $e');
    }
  }

  @override
  GameBoard? getCachedPuzzle(Difficulty difficulty) {
    try {
      final cacheKey = 'puzzle_${difficulty.name}';
      final cachedJson = _cacheService.getString(cacheKey);
      if (cachedJson != null) {
        final puzzleData = jsonDecode(cachedJson) as Map<String, dynamic>;
        return _gameBoardFromJson(puzzleData);
      }
      return null;
    } catch (e) {
      developer.log('캐시된 퍼즐 가져오기 실패: $e');
      return null;
    }
  }

  @override
  bool hasCachedPuzzle(Difficulty difficulty) {
    try {
      final cacheKey = 'puzzle_${difficulty.name}';
      return _cacheService.containsKey(cacheKey);
    } catch (e) {
      developer.log('캐시된 퍼즐 존재 여부 확인 실패: $e');
      return false;
    }
  }

  @override
  Future<void> clearCachedPuzzle(Difficulty difficulty) async {
    try {
      final cacheKey = 'puzzle_${difficulty.name}';
      await _cacheService.remove(cacheKey);
      developer.log('캐시된 퍼즐 삭제 완료 - 난이도: ${difficulty.name}');
    } catch (e) {
      developer.log('캐시된 퍼즐 삭제 실패: $e');
    }
  }

  /// Firebase 데이터를 GameBoard로 변환
  GameBoard _convertToGameBoard(Map<String, dynamic> puzzleData) {
    try {
      final puzzleId = puzzleData['puzzleId'] as String;
      final difficulty = Difficulty.values.firstWhere(
        (e) => e.name == puzzleData['difficulty'],
      );

      // 퍼즐 보드 데이터 파싱
      final puzzleBoardData = puzzleData['puzzleBoard'] as List<dynamic>;
      final solutionBoardData = puzzleData['solutionBoard'] as List<dynamic>;
      final chessPiecesData =
          puzzleData['chessPieces'] as Map<String, dynamic>?;

      // 퍼즐 보드 생성
      final puzzleBoard = _createSudokuBoard(puzzleBoardData, chessPiecesData);
      final solutionBoard = _createSudokuBoard(solutionBoardData, null);

      return GameBoard(
        board: puzzleBoard,
        solutionBoard: solutionBoard,
        difficulty: difficulty,
        puzzleId: puzzleId,
      );
    } catch (e) {
      developer.log('퍼즐 데이터 변환 실패: $e');
      rethrow;
    }
  }

  /// SudokuBoard 생성
  SudokuBoard _createSudokuBoard(
      List<dynamic> boardData, Map<String, dynamic>? chessPiecesData) {
    final puzzle = <List<int?>>[];
    final chessPieces = <Position, ChessPiece>{};

    // 보드 데이터 파싱
    for (int i = 0; i < boardData.length; i++) {
      final row = boardData[i] as List<dynamic>;
      final puzzleRow = <int?>[];

      for (int j = 0; j < row.length; j++) {
        final cell = row[j];
        if (cell == null) {
          puzzleRow.add(null);
        } else {
          puzzleRow.add(cell as int);
        }
      }
      puzzle.add(puzzleRow);
    }

    // 체스 기물 데이터 파싱
    if (chessPiecesData != null) {
      chessPiecesData.forEach((key, value) {
        final positionParts = key.split(',');
        final row = int.parse(positionParts[0]);
        final col = int.parse(positionParts[1]);
        final piece = ChessPiece.values.firstWhere(
          (e) => e.name == value,
        );

        chessPieces[Position(row: row, col: col)] = piece;
      });
    }

    return SudokuBoard.fromPuzzleWithChess(
      puzzle: puzzle,
      chessPieces: chessPieces,
    );
  }

  /// GameBoard를 JSON으로 변환
  Map<String, dynamic> _gameBoardToJson(GameBoard gameBoard) {
    return {
      'puzzleId': gameBoard.puzzleId,
      'difficulty': gameBoard.difficulty.name,
      'board': _sudokuBoardToJson(gameBoard.board),
      'solutionBoard': _sudokuBoardToJson(gameBoard.solutionBoard),
    };
  }

  /// JSON을 GameBoard로 변환
  GameBoard _gameBoardFromJson(Map<String, dynamic> json) {
    return GameBoard(
      board: _sudokuBoardFromJson(json['board'] as Map<String, dynamic>),
      solutionBoard:
          _sudokuBoardFromJson(json['solutionBoard'] as Map<String, dynamic>),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      puzzleId: json['puzzleId'] as String,
    );
  }

  /// SudokuBoard를 JSON으로 변환
  Map<String, dynamic> _sudokuBoardToJson(SudokuBoard board) {
    final puzzleJson = <List<int?>>[];
    final chessPiecesJson = <String, String>{};

    for (int i = 0; i < 9; i++) {
      final row = <int?>[];
      for (int j = 0; j < 9; j++) {
        final position = Position(row: i, col: j);
        final content = board.getCellContent(position);

        if (content?.chessPiece != null) {
          // 체스 기물이 있는 경우
          final key = '${position.row},${position.col}';
          chessPiecesJson[key] = content!.chessPiece!.name;
          row.add(null); // 체스 기물 위치는 숫자를 null로
        } else {
          // 숫자가 있는 경우
          row.add(content?.number);
        }
      }
      puzzleJson.add(row);
    }

    return {
      'puzzle': puzzleJson,
      'chessPieces': chessPiecesJson,
    };
  }

  /// JSON을 SudokuBoard로 변환
  SudokuBoard _sudokuBoardFromJson(Map<String, dynamic> json) {
    final puzzleData = json['puzzle'] as List<dynamic>;
    final chessPiecesData = json['chessPieces'] as Map<String, dynamic>;

    final puzzle = <List<int?>>[];
    for (final row in puzzleData) {
      final puzzleRow = <int?>[];
      for (final cell in row as List<dynamic>) {
        puzzleRow.add(cell as int?);
      }
      puzzle.add(puzzleRow);
    }

    final chessPieces = <Position, ChessPiece>{};
    chessPiecesData.forEach((key, value) {
      final positionParts = key.split(',');
      final row = int.parse(positionParts[0]);
      final col = int.parse(positionParts[1]);
      final piece = ChessPiece.values.firstWhere(
        (e) => e.name == value,
      );
      chessPieces[Position(row: row, col: col)] = piece;
    });

    return SudokuBoard.fromPuzzleWithChess(
      puzzle: puzzle,
      chessPieces: chessPieces,
    );
  }
}

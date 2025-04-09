import 'dart:convert';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/puzzle_action.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';

/// 퍼즐 데이터 처리를 담당하는 저장소
class PuzzleRepository {
  // 의존성 주입
  final CacheService _cacheService;

  // 상수 정의
  static const String _puzzleStateKeyPrefix = 'cached_puzzle_state';

  // 생성자
  PuzzleRepository(this._cacheService);

  // 난이도에 따른 캐시 키 생성
  String _getPuzzleStateKey([Difficulty? difficulty]) {
    if (difficulty == null) {
      return _puzzleStateKeyPrefix;
    }
    return '${_puzzleStateKeyPrefix}_${difficulty.name}';
  }

  /// 퍼즐 상태를 캐시에 저장
  Future<bool> savePuzzleState(PuzzleState state) async {
    try {
      final stateMap = _puzzleStateToMap(state);
      final stateJson = jsonEncode(stateMap);
      final key = _getPuzzleStateKey(state.difficulty);
      return await _cacheService.setString(key, stateJson);
    } catch (e) {
      print('퍼즐 상태 저장 중 오류 발생: $e');
      return false;
    }
  }

  /// 캐시에서 퍼즐 상태 불러오기
  Future<PuzzleState?> loadPuzzleState([Difficulty? difficulty]) async {
    try {
      final key = _getPuzzleStateKey(difficulty);
      final stateJson = _cacheService.getString(key);

      if (stateJson == null) {
        return null;
      }

      final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
      return _mapToPuzzleState(stateMap);
    } catch (e) {
      print('퍼즐 상태 불러오기 중 오류 발생: $e');
      return null;
    }
  }

  /// 캐시에서 퍼즐 상태 삭제
  Future<bool> clearPuzzleState([Difficulty? difficulty]) async {
    try {
      final key = _getPuzzleStateKey(difficulty);
      return await _cacheService.remove(key);
    } catch (e) {
      print('퍼즐 상태 삭제 중 오류 발생: $e');
      return false;
    }
  }

  /// 캐시된 퍼즐 상태 존재 여부 확인
  bool hasCachedPuzzleState([Difficulty? difficulty]) {
    try {
      final key = _getPuzzleStateKey(difficulty);
      return _cacheService.containsKey(key);
    } catch (e) {
      print('퍼즐 상태 확인 중 오류 발생: $e');
      return false;
    }
  }

  /// 퍼즐 상태를 Map으로 변환
  Map<String, dynamic> _puzzleStateToMap(PuzzleState state) {
    final boardMap = state.board.map((row) {
      return row.map((cell) {
        return {
          'number': cell.number,
          'chessPiece': cell.chessPiece?.index,
          'isInitial': cell.isInitial,
          'notes': cell.notes.toList(),
        };
      }).toList();
    }).toList();

    final historyList = state.history.map((action) {
      return {
        'row': action.row,
        'col': action.col,
        'oldContent': {
          'number': action.oldContent.number,
          'chessPiece': action.oldContent.chessPiece?.index,
          'isInitial': action.oldContent.isInitial,
          'notes': action.oldContent.notes.toList(),
        },
        'newContent': {
          'number': action.newContent.number,
          'chessPiece': action.newContent.chessPiece?.index,
          'isInitial': action.newContent.isInitial,
          'notes': action.newContent.notes.toList(),
        },
      };
    }).toList();

    return {
      'difficulty': state.difficulty.index,
      'board': boardMap,
      'selectedRow': state.selectedRow,
      'selectedCol': state.selectedCol,
      'isCompleted': state.isCompleted,
      'boardSize': state.boardSize,
      'elapsedTime': state.elapsedTime.inSeconds,
      'isTimerRunning': state.isTimerRunning,
      'isNoteMode': state.isNoteMode,
      'history': historyList,
      'historyIndex': state.historyIndex,
    };
  }

  /// Map에서 퍼즐 상태로 변환
  PuzzleState _mapToPuzzleState(Map<String, dynamic> map) {
    final boardData = map['board'] as List<dynamic>;
    final board = boardData.map((row) {
      return (row as List<dynamic>).map((cellData) {
        final cellMap = cellData as Map<String, dynamic>;
        final notesData = cellMap['notes'] as List<dynamic>;
        final notes = notesData.map((n) => n as int).toSet();

        final chessPieceIndex = cellMap['chessPiece'] as int?;
        final chessPiece =
            chessPieceIndex != null ? ChessPiece.values[chessPieceIndex] : null;

        return CellContent(
          number: cellMap['number'] as int?,
          chessPiece: chessPiece,
          isInitial: cellMap['isInitial'] as bool,
          notes: notes,
        );
      }).toList();
    }).toList();

    final historyData = map['history'] as List<dynamic>;
    final history = historyData.map((actionData) {
      final action = actionData as Map<String, dynamic>;
      final oldContentData = action['oldContent'] as Map<String, dynamic>;
      final newContentData = action['newContent'] as Map<String, dynamic>;

      final oldNotesData = oldContentData['notes'] as List<dynamic>;
      final oldNotes = oldNotesData.map((n) => n as int).toSet();

      final newNotesData = newContentData['notes'] as List<dynamic>;
      final newNotes = newNotesData.map((n) => n as int).toSet();

      final oldChessPieceIndex = oldContentData['chessPiece'] as int?;
      final oldChessPiece = oldChessPieceIndex != null
          ? ChessPiece.values[oldChessPieceIndex]
          : null;

      final newChessPieceIndex = newContentData['chessPiece'] as int?;
      final newChessPiece = newChessPieceIndex != null
          ? ChessPiece.values[newChessPieceIndex]
          : null;

      return PuzzleAction(
        row: action['row'] as int,
        col: action['col'] as int,
        oldContent: CellContent(
          number: oldContentData['number'] as int?,
          chessPiece: oldChessPiece,
          isInitial: oldContentData['isInitial'] as bool,
          notes: oldNotes,
        ),
        newContent: CellContent(
          number: newContentData['number'] as int?,
          chessPiece: newChessPiece,
          isInitial: newContentData['isInitial'] as bool,
          notes: newNotes,
        ),
      );
    }).toList();

    return PuzzleState(
      difficulty: Difficulty.values[map['difficulty'] as int],
      board: board,
      selectedRow: map['selectedRow'] as int?,
      selectedCol: map['selectedCol'] as int?,
      isCompleted: map['isCompleted'] as bool,
      boardSize: map['boardSize'] as int,
      elapsedTime: Duration(seconds: map['elapsedTime'] as int),
      isTimerRunning: map['isTimerRunning'] as bool,
      isNoteMode: map['isNoteMode'] as bool,
      history: history,
      historyIndex: map['historyIndex'] as int,
    );
  }
}

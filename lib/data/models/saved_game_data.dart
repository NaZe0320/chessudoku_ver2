import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/data/models/game_board.dart';
import 'package:chessudoku/data/models/sudoku_board.dart';
import 'package:chessudoku/data/models/position.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/data/models/checkpoint.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'dart:developer' as developer;

part 'saved_game_data.freezed.dart';

@freezed
class SavedGameData with _$SavedGameData {
  const factory SavedGameData({
    required GameBoard board,
    required int elapsedSeconds,
    required List<GameBoard> history,
    required List<GameBoard> redoHistory,
    required Difficulty difficulty,
    required DateTime savedAt,
    @Default({}) Map<String, Checkpoint> checkpoints, // 체크포인트 정보 추가
  }) = _SavedGameData;

  const SavedGameData._();

  Map<String, dynamic> toJson() {
    return {
      'board': _gameBoardToJson(board),
      'elapsedSeconds': elapsedSeconds,
      'history': history.map(_gameBoardToJson).toList(),
      'redoHistory': redoHistory.map(_gameBoardToJson).toList(),
      'difficulty': difficulty.name,
      'savedAt': savedAt.toIso8601String(),
      'checkpoints': checkpoints.map(
          (key, value) => MapEntry(key, _checkpointToJson(value))), // 체크포인트 직렬화
    };
  }

  factory SavedGameData.fromJson(Map<String, dynamic> json) {
    return SavedGameData(
      board: _gameBoardFromJson(json['board'] as Map<String, dynamic>),
      elapsedSeconds: json['elapsedSeconds'] as int,
      history: (json['history'] as List<dynamic>)
          .map((e) => _gameBoardFromJson(e as Map<String, dynamic>))
          .toList(),
      redoHistory: (json['redoHistory'] as List<dynamic>)
          .map((e) => _gameBoardFromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      savedAt: DateTime.parse(json['savedAt'] as String),
      checkpoints: json['checkpoints'] != null
          ? (json['checkpoints'] as Map<String, dynamic>).map((key, value) =>
              MapEntry(key, _checkpointFromJson(value as Map<String, dynamic>)))
          : {}, // 체크포인트 역직렬화
    );
  }

  static Map<String, dynamic> _gameBoardToJson(GameBoard board) {
    return {
      'board': _sudokuBoardToJson(board.board),
      'solutionBoard': _sudokuBoardToJson(board.solutionBoard),
      'selectedCell': board.selectedCell != null
          ? {
              'row': board.selectedCell!.row,
              'col': board.selectedCell!.col,
            }
          : null,
      'highlightedCells': board.highlightedCells
          .map((pos) => {'row': pos.row, 'col': pos.col})
          .toList(),
      'errorCells': board.errorCells
          .map((pos) => {'row': pos.row, 'col': pos.col})
          .toList(),
      'difficulty': board.difficulty.name,
      'puzzleId': board.puzzleId,
      'isNoteMode': board.isNoteMode,
    };
  }

  static GameBoard _gameBoardFromJson(Map<String, dynamic> json) {
    return GameBoard(
      board: _sudokuBoardFromJson(json['board'] as Map<String, dynamic>),
      solutionBoard:
          _sudokuBoardFromJson(json['solutionBoard'] as Map<String, dynamic>),
      selectedCell: json['selectedCell'] != null
          ? Position(
              row: json['selectedCell']['row'] as int,
              col: json['selectedCell']['col'] as int,
            )
          : null,
      highlightedCells: (json['highlightedCells'] as List<dynamic>)
          .map((e) => Position(
                row: e['row'] as int,
                col: e['col'] as int,
              ))
          .toSet(),
      errorCells: (json['errorCells'] as List<dynamic>)
          .map((e) => Position(
                row: e['row'] as int,
                col: e['col'] as int,
              ))
          .toSet(),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      puzzleId: json['puzzleId'] as String,
      isNoteMode: json['isNoteMode'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _sudokuBoardToJson(SudokuBoard board) {
    final cells = <Map<String, dynamic>>[];
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final content = board.getCellContent(Position(row: row, col: col));
        cells.add({
          'row': row,
          'col': col,
          'number': content?.number,
          'chessPiece': content?.chessPiece?.name,
          'notes': content?.notes.toList() ?? [],
          'isInitial': content?.isInitial ?? false,
        });
      }
    }
    return {'cells': cells};
  }

  static SudokuBoard _sudokuBoardFromJson(Map<String, dynamic> json) {
    SudokuBoard board = SudokuBoard.empty();
    final cells = json['cells'] as List<dynamic>;

    developer.log('SudokuBoard 역직렬화 시작 - 셀 개수: ${cells.length}',
        name: 'SavedGameData');

    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i];
      final row = cell['row'] as int;
      final col = cell['col'] as int;
      final number = cell['number'] as int?;
      final chessPieceName = cell['chessPiece'] as String?;
      final notes = (cell['notes'] as List<dynamic>).cast<int>().toSet();
      final isInitial = cell['isInitial'] as bool? ?? false;

      // 체스 기물 파싱
      ChessPiece? chessPiece;
      if (chessPieceName != null) {
        chessPiece = ChessPiece.values.firstWhere(
          (e) => e.name == chessPieceName,
          orElse: () => ChessPiece.pawn, // 기본값
        );
      }

      // 모든 셀을 생성 (빈 셀도 포함)
      board = board.setCellContent(
        Position(row: row, col: col),
        CellContent(
          number: number,
          chessPiece: chessPiece,
          notes: notes,
          isInitial: isInitial,
        ),
      );

      if (i < 5) {
        // 처음 5개 셀만 로그 출력
        developer.log(
            '셀 설정: ($row, $col) - 숫자: $number, 체스기물: $chessPieceName, 초기값: $isInitial, 현재 셀 수: ${board.cells.length}',
            name: 'SavedGameData');
      }
    }

    developer.log('SudokuBoard 역직렬화 완료 - 최종 셀 수: ${board.cells.length}',
        name: 'SavedGameData');
    return board;
  }

  // 체크포인트 직렬화 메서드
  static Map<String, dynamic> _checkpointToJson(Checkpoint checkpoint) {
    return {
      'board': _gameBoardToJson(checkpoint.board),
      'elapsedSeconds': checkpoint.elapsedSeconds,
      'history': checkpoint.history.map(_gameBoardToJson).toList(),
      'redoHistory': checkpoint.redoHistory.map(_gameBoardToJson).toList(),
      'createdAt': checkpoint.createdAt.toIso8601String(),
    };
  }

  // 체크포인트 역직렬화 메서드
  static Checkpoint _checkpointFromJson(Map<String, dynamic> json) {
    return Checkpoint(
      board: _gameBoardFromJson(json['board'] as Map<String, dynamic>),
      elapsedSeconds: json['elapsedSeconds'] as int,
      history: (json['history'] as List<dynamic>)
          .map((e) => _gameBoardFromJson(e as Map<String, dynamic>))
          .toList(),
      redoHistory: (json['redoHistory'] as List<dynamic>)
          .map((e) => _gameBoardFromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

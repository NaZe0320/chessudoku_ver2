import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/core/enums/difficulty.dart';
import 'package:flutter/foundation.dart';

part 'puzzle.freezed.dart';
part 'puzzle.g.dart';

/// 퍼즐 데이터 모델
@freezed
class Puzzle with _$Puzzle {
  const factory Puzzle({
    required String puzzleId,
    required Difficulty difficulty,
    required List<List<int?>> puzzle,
    required List<List<int?>> solution,
    required Map<String, String> chessPieces,
    required DateTime createdAt,
  }) = _Puzzle;

  const Puzzle._();

  /// JSON 직렬화를 위한 팩토리 메서드
  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);

  /// 서버 응답에서 퍼즐 생성
  factory Puzzle.fromServerResponse(Map<String, dynamic> json) {
    return Puzzle(
      puzzleId: json['puzzle_id'].toString(), // int를 String으로 변환
      difficulty: Difficulty.fromString(json['difficulty'] as String),
      puzzle: List<List<int?>>.from((json['puzzle_data']['board'] as List).map(
          (row) => List<int?>.from(
              (row as List).map((cell) => cell == 0 ? null : cell as int?)))),
      solution: List<List<int?>>.from((json['answer_data']['board'] as List)
          .map((row) => List<int?>.from(
              (row as List).map((cell) => cell == 0 ? null : cell as int?)))),
      chessPieces: _parseChessPieces(json['puzzle_data']['pieces'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// 체스 기물 데이터를 Map<String, String>으로 변환
  static Map<String, String> _parseChessPieces(List pieces) {
    final chessPieces = <String, String>{};
    for (final piece in pieces) {
      final pieceData = piece as Map<String, dynamic>;
      final type = pieceData['type'] as String;
      final position = pieceData['position'] as List;
      final row = position[0] as int;
      final col = position[1] as int;
      chessPieces['$row,$col'] = type;
    }
    return chessPieces;
  }

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toServerJson() {
    return {
      'puzzle_id': puzzleId,
      'difficulty': difficulty.name,
      'puzzle': puzzle,
      'solution': solution,
      'chess_pieces': chessPieces,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

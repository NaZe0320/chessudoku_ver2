import 'dart:convert';

import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

/// 완료된 퍼즐의 기록 정보를 담는 모델 클래스
class PuzzleRecord {
  // ID (데이터베이스의 프라이머리 키)
  final int? id;
  // 난이도
  final Difficulty difficulty;
  // 보드 데이터 (완성된 퍼즐 내용)
  final List<List<CellContent>> boardData;
  // 완료 시간 (초)
  final Duration completionTime;
  // 생성 일시
  final DateTime createdAt;

  PuzzleRecord({
    this.id,
    required this.difficulty,
    required this.boardData,
    required this.completionTime,
    required this.createdAt,
  });

  /// Map에서 PuzzleRecord 객체 생성 (DB에서 데이터 로드 시 사용)
  factory PuzzleRecord.fromMap(Map<String, dynamic> map) {
    // 보드 데이터 파싱
    final boardDataJson = json.decode(map['boardData'] as String);
    final boardData = (boardDataJson as List<dynamic>).map((row) {
      return (row as List<dynamic>).map((cell) {
        final cellMap = cell as Map<String, dynamic>;
        return CellContent(
          number: cellMap['number'] as int?,
          chessPiece: cellMap['chessPiece'] != null
              ? ChessPiece.values[cellMap['chessPiece'] as int]
              : null,
          isInitial: cellMap['isInitial'] as bool? ?? false,
          notes: (cellMap['notes'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toSet() ??
              {},
        );
      }).toList();
    }).toList();

    return PuzzleRecord(
      id: map['id'] as int?,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      boardData: boardData,
      completionTime: Duration(seconds: map['completionTime'] as int),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// PuzzleRecord 객체를 Map으로 변환 (DB에 저장 시 사용)
  Map<String, dynamic> toMap() {
    // 보드 데이터를 직렬화
    final boardDataMap = boardData.map((row) {
      return row.map((cell) {
        return {
          'number': cell.number,
          'chessPiece': cell.chessPiece?.index,
          'isInitial': cell.isInitial,
          'notes': cell.notes.toList(),
        };
      }).toList();
    }).toList();

    return {
      'id': id,
      'difficulty': difficulty.name,
      'boardData': json.encode(boardDataMap),
      'completionTime': completionTime.inSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 포맷된 완료 시간 문자열 (mm:ss)
  String get formattedCompletionTime {
    final minutes =
        completionTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        completionTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 객체의 문자열 표현
  @override
  String toString() {
    return 'PuzzleRecord(id: $id, difficulty: ${difficulty.name}, completionTime: $formattedCompletionTime, createdAt: ${createdAt.toIso8601String()})';
  }
}

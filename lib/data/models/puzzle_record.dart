import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

part 'puzzle_record.freezed.dart';
part 'puzzle_record.g.dart';

@freezed
class PuzzleRecord with _$PuzzleRecord {
  const factory PuzzleRecord({
    required String recordId,
    required String puzzleId,
    required Difficulty difficulty,
    required DateTime completedAt,
    required int elapsedSeconds,
    @Default(0) int hintCount,
  }) = _PuzzleRecord;

  factory PuzzleRecord.fromJson(Map<String, dynamic> json) =>
      _$PuzzleRecordFromJson(json);
}

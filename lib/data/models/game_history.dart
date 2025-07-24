import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';

part 'game_history.freezed.dart';
part 'game_history.g.dart';

@freezed
class GameHistory with _$GameHistory {
  const factory GameHistory({
    required String puzzleId,
    required Difficulty difficulty,
    required DateTime completedAt,
    required int playTimeSeconds,
    @Default(false) bool isCompleted,
  }) = _GameHistory;

  factory GameHistory.fromJson(Map<String, dynamic> json) =>
      _$GameHistoryFromJson(json);
}

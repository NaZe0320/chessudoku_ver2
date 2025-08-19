import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chessudoku/domain/enums/day_status.dart';

part 'day_progress.freezed.dart';

@freezed
class DayProgress with _$DayProgress {
  const factory DayProgress({
    required String label,
    required DayStatus status,
  }) = _DayProgress;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    @Default(0.0) double progress,
    @Default('초기화 중...') String message,
    @Default(false) bool isCompleted,
  }) = _SyncState;
}

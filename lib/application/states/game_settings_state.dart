import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_settings_state.freezed.dart';

@freezed
class GameSettingsState with _$GameSettingsState {
  const factory GameSettingsState({
    @Default(true) bool highlightSameNumbers,
    @Default(true) bool showScopeOnSelect,
    @Default(true) bool autoNoteClear,
  }) = _GameSettingsState;
}

class GameSettingsState {
  final bool highlightSameNumbers;
  final bool showScopeOnSelect;
  final bool autoNoteClear;

  const GameSettingsState({
    this.highlightSameNumbers = true,
    this.showScopeOnSelect = true,
    this.autoNoteClear = true,
  });

  GameSettingsState copyWith({
    bool? highlightSameNumbers,
    bool? showScopeOnSelect,
    bool? autoNoteClear,
  }) {
    return GameSettingsState(
      highlightSameNumbers: highlightSameNumbers ?? this.highlightSameNumbers,
      showScopeOnSelect: showScopeOnSelect ?? this.showScopeOnSelect,
      autoNoteClear: autoNoteClear ?? this.autoNoteClear,
    );
  }
}

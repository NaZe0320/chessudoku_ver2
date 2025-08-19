import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/presentation/states/game_settings_state.dart';

class GameSettingsNotifier extends StateNotifier<GameSettingsState> {
  final CacheService _cacheService;

  static const String _keyHighlightSameNumbers = 'gs_highlight_same_numbers';
  static const String _keyShowScopeOnSelect = 'gs_show_scope_on_select';
  static const String _keyAutoNoteClear = 'gs_auto_note_clear';

  GameSettingsNotifier(this._cacheService) : super(const GameSettingsState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheService.init();

    final highlight = _cacheService.getBool(_keyHighlightSameNumbers) ??
        state.highlightSameNumbers;
    final scope =
        _cacheService.getBool(_keyShowScopeOnSelect) ?? state.showScopeOnSelect;
    final auto =
        _cacheService.getBool(_keyAutoNoteClear) ?? state.autoNoteClear;

    state = state.copyWith(
      highlightSameNumbers: highlight,
      showScopeOnSelect: scope,
      autoNoteClear: auto,
    );
  }

  Future<void> toggleHighlightSameNumbers() async {
    final newValue = !state.highlightSameNumbers;
    state = state.copyWith(highlightSameNumbers: newValue);
    await _cacheService.setBool(_keyHighlightSameNumbers, newValue);
  }

  Future<void> toggleShowScopeOnSelect() async {
    final newValue = !state.showScopeOnSelect;
    state = state.copyWith(showScopeOnSelect: newValue);
    await _cacheService.setBool(_keyShowScopeOnSelect, newValue);
  }

  Future<void> toggleAutoNoteClear() async {
    final newValue = !state.autoNoteClear;
    state = state.copyWith(autoNoteClear: newValue);
    await _cacheService.setBool(_keyAutoNoteClear, newValue);
  }
}

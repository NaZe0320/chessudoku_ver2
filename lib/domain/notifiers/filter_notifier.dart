import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/filter_type.dart';
import 'package:chessudoku/domain/intents/filter_intent.dart';
import 'package:chessudoku/domain/states/filter_state.dart';

class FilterNotifier<T> extends BaseNotifier<FilterIntent<T>, FilterState<T>> {
  FilterNotifier() : super(FilterState<T>());

  @override
  void onIntent(FilterIntent<T> intent) {
    switch (intent) {
      case SelectFilterIntent<T>():
        _selectOption(intent.optionId);
        break;
      case SelectAllIntent<T>():
        _selectAll();
        break;
      case SetFilterOptionsIntent<T>():
        _setFilterOptions(
            intent.options, intent.filterType, intent.showAllOption);
        break;
    }
  }

  void _selectOption(String optionId) {
    if (optionId == 'all') {
      _selectAll();
      return;
    }

    final updatedOptions = <FilterOption<T>>[];

    for (final option in state.options) {
      if (option.id == optionId) {
        if (state.filterType == FilterType.single) {
          // 단일 선택: 토글 없이 항상 선택
          updatedOptions.add(option.copyWith(isSelected: true));
        } else {
          // 다중 선택: 토글 기능
          updatedOptions.add(option.copyWith(isSelected: !option.isSelected));
        }
      } else if (state.filterType == FilterType.single) {
        // 단일 선택: 다른 옵션들 모두 비선택
        updatedOptions.add(option.copyWith(isSelected: false));
      } else {
        // 다중 선택: 기존 상태 유지
        updatedOptions.add(option);
      }
    }

    state = state.copyWith(
      options: updatedOptions,
      isAllSelected: false,
    );
  }

  void _selectAll() {
    // 모든 개별 옵션 해제
    final clearedOptions = state.options
        .map((option) => option.copyWith(isSelected: false))
        .toList();

    state = state.copyWith(
      options: clearedOptions,
      isAllSelected: true,
    );
  }

  void _setFilterOptions(
    List<FilterOption<T>> options,
    FilterType filterType,
    bool showAllOption,
  ) {
    state = state.copyWith(
      options: options,
      filterType: filterType,
      showAllOption: showAllOption,
      isAllSelected: true,
      isLoading: false,
      error: null,
    );
  }

  /// 필터 초기화
  void reset() {
    final clearedOptions = state.options
        .map((option) => option.copyWith(isSelected: false))
        .toList();

    state = state.copyWith(
      options: clearedOptions,
      isAllSelected: true,
      error: null,
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  @override
  void handleError(Object error, StackTrace stackTrace) {
    super.handleError(error, stackTrace);

    // 🔥 필터 관련 에러 처리
    state = state.copyWith(
      error: error.toString(),
      isLoading: false,
    );
  }
}

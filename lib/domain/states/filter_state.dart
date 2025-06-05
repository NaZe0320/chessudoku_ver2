import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/filter_type.dart';

class FilterState<T> {
  final List<FilterOption<T>> options;
  final FilterType filterType;
  final bool isLoading;
  final String? error;
  final bool showAllOption;
  final bool isAllSelected;

  const FilterState._({
    required this.options,
    this.filterType = FilterType.single,
    this.isLoading = false,
    this.error,
    this.showAllOption = true,
    this.isAllSelected = false,
  });

  // 팩토리 생성자로 기본값 제공
  factory FilterState({
    List<FilterOption<T>>? options,
    FilterType? filterType,
    bool? isLoading,
    String? error,
    bool? showAllOption,
    bool? isAllSelected,
  }) {
    return FilterState._(
      options: options ?? <FilterOption<T>>[],
      filterType: filterType ?? FilterType.single,
      isLoading: isLoading ?? false,
      error: error,
      showAllOption: showAllOption ?? true,
      isAllSelected: isAllSelected ?? true,
    );
  }

  FilterState<T> copyWith({
    List<FilterOption<T>>? options,
    FilterType? filterType,
    bool? isLoading,
    String? error,
    bool? showAllOption,
    bool? isAllSelected,
  }) {
    return FilterState._(
      options: options ?? this.options,
      filterType: filterType ?? this.filterType,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showAllOption: showAllOption ?? this.showAllOption,
      isAllSelected: isAllSelected ?? this.isAllSelected,
    );
  }

  // 선택된 옵션들 가져오기
  List<FilterOption<T>> get selectedOptions {
    return options.where((option) => option.isSelected).toList();
  }

  // 선택된 값들 가져오기
  List<T> get selectedValues {
    return selectedOptions.map((option) => option.value).toList();
  }

  // 특정 옵션이 선택되었는지 확인
  bool isSelected(String optionId) {
    return options.any((option) => option.id == optionId && option.isSelected);
  }

  // 선택된 옵션이 있는지 확인
  bool get hasSelectedOptions {
    return options.any((option) => option.isSelected);
  }

  // 전체 옵션을 포함한 모든 옵션 리스트
  List<FilterOption<T>> get allOptionsWithAll {
    if (!showAllOption || options.isEmpty) {
      return options;
    }

    // 전체 옵션을 맨 앞에 추가 (첫 번째 옵션의 value를 사용)
    final allOption = FilterOption<T>(
      id: 'all',
      label: '전체',
      value: options.first.value,
      isSelected: isAllSelected,
    );

    return [allOption, ...options];
  }

  // 실제 필터링에 사용할 값들 (전체인 경우 모든 값)
  List<T> get effectiveFilterValues {
    if (isAllSelected) {
      return options.map((option) => option.value).toList();
    }
    return selectedValues;
  }
}

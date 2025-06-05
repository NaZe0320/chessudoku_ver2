import 'package:chessudoku/core/base/base_intent.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/filter_type.dart';

abstract class FilterIntent<T> extends BaseIntent {
  const FilterIntent();
}
 
class SelectFilterIntent<T> extends FilterIntent<T> {
  final String optionId;

  const SelectFilterIntent({
    required this.optionId,
  });
}

class SelectAllIntent<T> extends FilterIntent<T> {
  const SelectAllIntent();
}

class SetFilterOptionsIntent<T> extends FilterIntent<T> {
  final List<FilterOption<T>> options;
  final FilterType filterType;
  final bool showAllOption;

  const SetFilterOptionsIntent({
    required this.options,
    required this.filterType,
    this.showAllOption = true,
  });
}

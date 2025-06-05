import 'package:chessudoku/domain/notifiers/filter_notifier.dart';
import 'package:chessudoku/domain/states/filter_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendPackTypeFilterProvider =
    StateNotifierProvider<FilterNotifier<String>, FilterState<String>>((ref) {
  return FilterNotifier<String>();
});

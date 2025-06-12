import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/notifiers/filter_notifier.dart';
import 'package:chessudoku/domain/notifiers/puzzle_pack_notifier.dart';
import 'package:chessudoku/domain/states/filter_state.dart';
import 'package:chessudoku/domain/states/puzzle_pack_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendPackTypeFilterProvider =
    StateNotifierProvider<FilterNotifier<String>, FilterState<String>>((ref) {
  return FilterNotifier<String>();
});

/// 퍼즐 팩 관리 Provider
final puzzlePackNotifierProvider =
    StateNotifierProvider<PuzzlePackNotifier, PuzzlePackState>((ref) {
  final puzzleRepository = ref.watch(puzzleRepositoryProvider);
  return PuzzlePackNotifier(puzzleRepository);
});

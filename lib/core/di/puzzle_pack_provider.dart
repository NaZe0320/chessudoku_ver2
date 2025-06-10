import 'package:chessudoku/data/datasources/puzzle_pack_datasource.dart';
import 'package:chessudoku/data/repositories/puzzle_pack_repository_impl.dart';
import 'package:chessudoku/domain/notifiers/filter_notifier.dart';
import 'package:chessudoku/domain/notifiers/puzzle_pack_notifier.dart';
import 'package:chessudoku/domain/repositories/puzzle_pack_repository.dart';
import 'package:chessudoku/domain/states/filter_state.dart';
import 'package:chessudoku/domain/states/puzzle_pack_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== DataSource Providers =====
final puzzlePackDatabaseDataSourceProvider =
    Provider<PuzzlePackDatabaseDataSource>((ref) {
  return PuzzlePackDatabaseDataSource();
});

// ===== Repository Providers =====
final puzzlePackRepositoryProvider = Provider<PuzzlePackRepository>((ref) {
  final databaseDataSource = ref.watch(puzzlePackDatabaseDataSourceProvider);

  return PuzzlePackRepositoryImpl(
    localDataSource: databaseDataSource, // 데이터베이스를 메인 데이터소스로 사용
    databaseDataSource: databaseDataSource,
  );
});

// ===== Notifier Providers =====
final puzzlePackNotifierProvider =
    StateNotifierProvider<PuzzlePackNotifier, PuzzlePackState>((ref) {
  final repository = ref.watch(puzzlePackRepositoryProvider);
  return PuzzlePackNotifier(repository: repository);
});

// ===== Filter Providers =====
final recommendPackTypeFilterProvider =
    StateNotifierProvider<FilterNotifier<String>, FilterState<String>>((ref) {
  return FilterNotifier<String>();
});

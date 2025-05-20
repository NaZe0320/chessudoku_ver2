import 'package:chessudoku/domain/notifiers/puzzle_creation_notifier.dart';
import 'package:chessudoku/domain/states/puzzle_creation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 퍼즐 생성 관련 provider
final puzzleCreationProvider =
    StateNotifierProvider<PuzzleCreationNotifier, PuzzleCreationState>(
  (ref) => PuzzleCreationNotifier(),
  name: 'puzzleCreationProvider',
);

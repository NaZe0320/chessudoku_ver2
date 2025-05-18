// 퍼즐 관련 프로바이더
import 'package:chessudoku/legacy/puzzle_intent.dart';
import 'package:chessudoku/legacy/puzzle_notifier.dart';
import 'package:chessudoku/legacy/puzzle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final puzzleNotifierProvider =
    StateNotifierProvider<PuzzleNotifier, PuzzleState>(
  (ref) => PuzzleNotifier(),
);

// 퍼즐 상태 프로바이더 (읽기 전용)
final puzzleProvider = Provider<PuzzleState>(
  (ref) => ref.watch(puzzleNotifierProvider),
);

// 퍼즐 인텐트 프로바이더
final puzzleIntentProvider = Provider<PuzzleIntent>(
  (ref) => PuzzleIntent(ref),
);
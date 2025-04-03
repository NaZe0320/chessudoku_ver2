import 'package:chessudoku/domain/notifiers/navigation_notifier.dart';
import 'package:chessudoku/domain/notifiers/puzzle_notifier.dart';
import 'package:chessudoku/domain/states/navigation_state.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
        (ref) => NavigationNotifier());
final puzzleProvider = StateNotifierProvider<PuzzleNotifier, PuzzleState>(
    (ref) => PuzzleNotifier());

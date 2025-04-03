import 'package:chessudoku/data/repositories/puzzle_repository.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/domain/intents/puzzle_intent.dart';
import 'package:chessudoku/domain/intents/select_tab_intent.dart';
import 'package:chessudoku/domain/notifiers/navigation_notifier.dart';
import 'package:chessudoku/domain/notifiers/puzzle_notifier.dart';
import 'package:chessudoku/domain/states/navigation_state.dart';
import 'package:chessudoku/domain/states/puzzle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 네비게이션 관련 프로바이더
final navigationNotifierProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);

// 네비게이션 상태 프로바이더 (읽기 전용)
final navigationProvider = Provider<NavigationState>(
  (ref) => ref.watch(navigationNotifierProvider),
);

// 네비게이션 인텐트 프로바이더
final navigationIntentProvider = Provider<SelectTabIntent>(
  (ref) => SelectTabIntent(ref),
);

// 퍼즐 관련 프로바이더
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

// 캐시 서비스 프로바이더 (싱글톤)
final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

// 퍼즐 레포지토리 프로바이더
final puzzleRepositoryProvider = Provider<PuzzleRepository>(
  (ref) => PuzzleRepository(ref.watch(cacheServiceProvider)),
);

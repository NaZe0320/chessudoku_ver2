import 'package:chessudoku/data/repositories/puzzle_repository.dart';
import 'package:chessudoku/data/repositories/record_repository.dart';
import 'package:chessudoku/data/services/cache_service.dart';
import 'package:chessudoku/data/services/database_service.dart';
import 'package:chessudoku/domain/intents/records_intent.dart';
import 'package:chessudoku/domain/notifiers/loading_notifier.dart';
import 'package:chessudoku/domain/notifiers/records_notifier.dart';
import 'package:chessudoku/domain/states/loading_state.dart';
import 'package:chessudoku/domain/states/records_state.dart';
import 'package:chessudoku/core/utils/chess_sudoku_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 로딩 상태 관리를 위한 Provider
final loadingNotifierProvider = 
    StateNotifierProvider<LoadingNotifier, LoadingState>(
  (ref) => LoadingNotifier(),
);

// 기록 관련 프로바이더
final recordsNotifierProvider =
    StateNotifierProvider<RecordsNotifier, RecordsState>(
  (ref) => RecordsNotifier(),
);

// 기록 상태 프로바이더 (읽기 전용)
final recordsProvider = Provider<RecordsState>(
  (ref) => ref.watch(recordsNotifierProvider),
);

// 기록 인텐트 프로바이더
final recordsIntentProvider = Provider<RecordsIntent>(
  (ref) => RecordsIntent(ref),
);

// 캐시 서비스 프로바이더 (싱글톤)
final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

// 데이터베이스 서비스 프로바이더 (싱글톤)
final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService());

// 퍼즐 레포지토리 프로바이더
final puzzleRepositoryProvider = Provider<PuzzleRepository>(
  (ref) => PuzzleRepository(ref.watch(cacheServiceProvider)),
);

// 기록 레포지토리 프로바이더
final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(databaseServiceProvider)),
);

// 체스도쿠 생성기 Provider (싱글톤)
final chessSudokuGeneratorProvider = Provider<ChessSudokuGenerator>(
  (ref) => ChessSudokuGenerator(),
);

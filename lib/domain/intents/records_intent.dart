import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/notifiers/records_notifier.dart';
import 'package:chessudoku/domain/states/records_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 기록실 화면의 동작을 처리하는 인텐트 클래스
class RecordsIntent {
  final Ref ref;

  RecordsIntent(this.ref);

  /// 노티파이어에 대한 참조 getter
  RecordsNotifier get _notifier => ref.read(recordsNotifierProvider.notifier);

  /// 현재 상태 getter
  RecordsState get _state => ref.read(recordsProvider);

  /// 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    _notifier.changeDifficulty(difficulty);
    loadBestRecord();
    loadRecords();
  }

  /// 최고 기록 로드
  Future<void> loadBestRecord() async {
    try {
      final intent = ref.read(puzzleIntentProvider);
      final bestRecord =
          await intent.getBestRecordByDifficulty(_state.difficulty);
      _notifier.setBestRecord(bestRecord);
    } catch (e) {
      print('최고 기록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 페이지네이션으로 기록 로드
  Future<void> loadRecords() async {
    // 이미 로딩 중이거나 더 이상 불러올 기록이 없는 경우
    if (_state.isLoading || !_state.hasMoreRecords) return;

    _notifier.setLoading(true);

    try {
      final intent = ref.read(puzzleIntentProvider);
      final records = await intent.getRecordsByDifficulty(_state.difficulty);

      // 페이지네이션 처리
      final startIdx = _state.currentPage * _state.itemsPerPage;
      final endIdx = startIdx + _state.itemsPerPage;

      if (startIdx >= records.length) {
        _notifier.setHasMoreRecords(false);
        _notifier.setLoadComplete();
        return;
      }

      // 한 페이지 분량의 기록만 추가
      final pageRecords = records.sublist(
          startIdx, endIdx > records.length ? records.length : endIdx);

      _notifier.addRecords(pageRecords);
      _notifier.setHasMoreRecords(endIdx < records.length);
      _notifier.setLoadComplete();
    } catch (e) {
      _notifier.setLoadComplete();
      print('기록을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 모든 기록 새로고침
  Future<void> refreshRecords() async {
    _notifier.resetRecords();
    await loadBestRecord();
    await loadRecords();
  }
}

import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/di/puzzle_provider.dart';
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
      print('RecordsIntent: 최고 기록 로드 시작 - 난이도: ${_state.difficulty.name}');
      final intent = ref.read(puzzleIntentProvider);
      final bestRecord =
          await intent.getBestRecordByDifficulty(_state.difficulty);

      print(
          'RecordsIntent: 최고 기록 로드 결과: ${bestRecord != null ? '성공' : '기록 없음'}');
      if (bestRecord != null) {
        print(
            'RecordsIntent: 최고 기록 시간: ${bestRecord['completionTime']}, 날짜: ${bestRecord['createdAt']}');
      }

      _notifier.setBestRecord(bestRecord);
    } catch (e, stackTrace) {
      print('RecordsIntent: 최고 기록을 불러오는 중 오류가 발생했습니다: $e');
      print('RecordsIntent: StackTrace: $stackTrace');
    }
  }

  /// 페이지네이션으로 기록 로드
  Future<void> loadRecords() async {
    // 이미 로딩 중이거나 더 이상 불러올 기록이 없는 경우
    if (_state.isLoading || !_state.hasMoreRecords) {
      print(
          'RecordsIntent: 로딩 중이거나 더이상 기록이 없어 로드를 건너뜁니다. isLoading: ${_state.isLoading}, hasMoreRecords: ${_state.hasMoreRecords}');
      return;
    }

    _notifier.setLoading(true);
    print(
        'RecordsIntent: 기록 로드 시작 - 난이도: ${_state.difficulty.name}, 페이지: ${_state.currentPage + 1}');

    try {
      final intent = ref.read(puzzleIntentProvider);
      final allRecords = await intent.getRecordsByDifficulty(_state.difficulty);

      print('RecordsIntent: 전체 기록 수: ${allRecords.length}개');

      // 이미 로드된 기록 개수
      final loadedCount = _state.records.length;
      print('RecordsIntent: 현재 로드된 기록 수: $loadedCount개');

      // 페이지네이션 처리
      final startIdx = loadedCount;
      final endIdx = startIdx + _state.itemsPerPage;

      print('RecordsIntent: 페이지네이션 범위 - startIdx: $startIdx, endIdx: $endIdx');

      if (startIdx >= allRecords.length) {
        print('RecordsIntent: 더 이상 로드할 기록이 없습니다.');
        _notifier.setHasMoreRecords(false);
        _notifier.setLoadComplete();
        return;
      }

      // 한 페이지 분량의 기록만 추가
      final pageRecords = allRecords.sublist(
          startIdx, endIdx > allRecords.length ? allRecords.length : endIdx);

      print('RecordsIntent: 이번에 로드한 기록 수: ${pageRecords.length}개');

      // 기록이 있으면 로그 출력
      if (pageRecords.isNotEmpty) {
        print(
            'RecordsIntent: 첫 번째 기록 - 시간: ${pageRecords.first['completionTime']}, 날짜: ${pageRecords.first['createdAt']}');
        if (pageRecords.length > 1) {
          print(
              'RecordsIntent: 마지막 기록 - 시간: ${pageRecords.last['completionTime']}, 날짜: ${pageRecords.last['createdAt']}');
        }
      }

      _notifier.addRecords(pageRecords);
      _notifier.setHasMoreRecords(endIdx < allRecords.length);
      _notifier.setLoadComplete();
    } catch (e, stackTrace) {
      _notifier.setLoadComplete();
      print('RecordsIntent: 기록을 불러오는 중 오류가 발생했습니다: $e');
      print('RecordsIntent: StackTrace: $stackTrace');
    }
  }

  /// 모든 기록 새로고침
  Future<void> refreshRecords() async {
    print('RecordsIntent: 모든 기록 새로고침 시작');
    _notifier.resetRecords();
    await loadBestRecord();
    await loadRecords();
    print('RecordsIntent: 모든 기록 새로고침 완료');
  }
}

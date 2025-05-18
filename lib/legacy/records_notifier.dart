import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/legacy/records_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 기록실 상태를 관리하는 노티파이어
class RecordsNotifier extends StateNotifier<RecordsState> {
  RecordsNotifier() : super(const RecordsState());

  /// 난이도 변경
  void changeDifficulty(Difficulty difficulty) {
    state = state.copyWith(
      difficulty: difficulty,
      records: [],
      currentPage: 0,
      hasMoreRecords: true,
      clearBestRecord: true,
      isLoading: false,
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 최고 기록 설정
  void setBestRecord(Map<String, dynamic>? bestRecord) {
    state = state.copyWith(bestRecord: bestRecord);
  }

  /// 더 많은 기록 로드 여부 설정
  void setHasMoreRecords(bool hasMoreRecords) {
    state = state.copyWith(hasMoreRecords: hasMoreRecords);
  }

  /// 기록 추가
  void addRecords(List<Map<String, dynamic>> newRecords) {
    if (newRecords.isEmpty) {
      state = state.copyWith(hasMoreRecords: false, isLoading: false);
      return;
    }

    state = state.addRecords(newRecords);
  }

  /// 기록 초기화
  void resetRecords() {
    state = state.resetRecords();
  }

  /// 데이터 로드 완료
  void setLoadComplete() {
    state = state.copyWith(isLoading: false);
  }
}

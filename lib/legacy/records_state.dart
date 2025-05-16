import 'package:chessudoku/domain/enums/difficulty.dart';

/// 기록실 페이지의 상태를 관리하는 클래스
class RecordsState {
  final Difficulty difficulty;
  final List<Map<String, dynamic>> records;
  final Map<String, dynamic>? bestRecord;
  final bool isLoading;
  final bool hasMoreRecords;
  final int currentPage;
  final int itemsPerPage;

  const RecordsState({
    this.difficulty = Difficulty.easy,
    this.records = const [],
    this.bestRecord,
    this.isLoading = false,
    this.hasMoreRecords = true,
    this.currentPage = 0,
    this.itemsPerPage = 10,
  });

  /// 깊은 복사를 위한 copyWith 메서드
  RecordsState copyWith({
    Difficulty? difficulty,
    List<Map<String, dynamic>>? records,
    Map<String, dynamic>? bestRecord,
    bool? isLoading,
    bool? hasMoreRecords,
    int? currentPage,
    int? itemsPerPage,
    bool clearBestRecord = false,
  }) {
    return RecordsState(
      difficulty: difficulty ?? this.difficulty,
      records: records ?? this.records,
      bestRecord: clearBestRecord ? null : (bestRecord ?? this.bestRecord),
      isLoading: isLoading ?? this.isLoading,
      hasMoreRecords: hasMoreRecords ?? this.hasMoreRecords,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  /// 기록 리스트 초기화
  RecordsState resetRecords() {
    return copyWith(
      records: [],
      currentPage: 0,
      hasMoreRecords: true,
      clearBestRecord: true,
    );
  }

  /// 기록 리스트에 새 기록 추가
  RecordsState addRecords(List<Map<String, dynamic>> newRecords) {
    final updatedRecords = List<Map<String, dynamic>>.from(records)
      ..addAll(newRecords);

    return copyWith(
      records: updatedRecords,
      currentPage: currentPage + 1,
    );
  }
}

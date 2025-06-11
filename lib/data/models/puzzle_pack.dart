
/// 퍼즐팩 정보를 담는 모델 클래스
class PuzzlePack {
  final String id;
  final String name;
  final int totalPuzzles;
  final List<String> type;
  final bool isPremium;
  final String iconAsset;
  final int completedPuzzles;
  final List<int> puzzleIds;

  const PuzzlePack({
    required this.id,
    required this.name,
    required this.totalPuzzles,
    required this.type,
    this.isPremium = false,
    required this.iconAsset,
    this.completedPuzzles = 0,
    required this.puzzleIds,
  });

  /// 완료율 계산 (0.0 ~ 1.0)
  double get completionRate =>
      totalPuzzles > 0 ? completedPuzzles / totalPuzzles : 0.0;

  /// 진행 상태 텍스트
  String get progressText => '$completedPuzzles/$totalPuzzles';

  /// 완료 여부
  bool get isCompleted => completedPuzzles >= totalPuzzles;
}

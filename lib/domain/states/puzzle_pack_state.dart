import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/data/models/filter_option.dart';

/// 퍼즐팩 관리를 위한 상태 클래스
class PuzzlePackState {
  final List<PuzzlePack> puzzlePacks;
  final List<PuzzlePack> recommendedPacks;
  final List<PuzzlePack> filteredRecommendedPacks;
  final List<FilterOption<String>> recommendedPackFilterOptions;
  final List<String> selectedRecommendedPackTypes;
  final List<PuzzlePack> premiumPacks;
  final bool isLoading;
  final String? error;
  final Difficulty? selectedDifficulty;
  final String? selectedType;

  const PuzzlePackState({
    this.puzzlePacks = const [],
    this.recommendedPacks = const [],
    this.filteredRecommendedPacks = const [],
    this.recommendedPackFilterOptions = const [],
    this.selectedRecommendedPackTypes = const [],
    this.premiumPacks = const [],
    this.isLoading = false,
    this.error,
    this.selectedDifficulty,
    this.selectedType,
  });

  /// 상태 복사 메서드
  PuzzlePackState copyWith({
    List<PuzzlePack>? puzzlePacks,
    List<PuzzlePack>? recommendedPacks,
    List<PuzzlePack>? filteredRecommendedPacks,
    List<FilterOption<String>>? recommendedPackFilterOptions,
    List<String>? selectedRecommendedPackTypes,
    List<PuzzlePack>? premiumPacks,
    bool? isLoading,
    String? error,
    Difficulty? selectedDifficulty,
    String? selectedType,
  }) {
    return PuzzlePackState(
      puzzlePacks: puzzlePacks ?? this.puzzlePacks,
      recommendedPacks: recommendedPacks ?? this.recommendedPacks,
      filteredRecommendedPacks:
          filteredRecommendedPacks ?? this.filteredRecommendedPacks,
      recommendedPackFilterOptions:
          recommendedPackFilterOptions ?? this.recommendedPackFilterOptions,
      selectedRecommendedPackTypes:
          selectedRecommendedPackTypes ?? this.selectedRecommendedPackTypes,
      premiumPacks: premiumPacks ?? this.premiumPacks,
      isLoading: isLoading ?? this.isLoading,
      error: error, // null을 허용하기 위해 ?? 사용하지 않음
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  /// 에러 상태 여부
  bool get hasError => error != null;

  /// 데이터 로드 완료 여부
  bool get hasData => puzzlePacks.isNotEmpty;

  /// 추천팩 로드 완료 여부
  bool get hasRecommendedPacks => recommendedPacks.isNotEmpty;

  /// 프리미엄팩 로드 완료 여부
  bool get hasPremiumPacks => premiumPacks.isNotEmpty;

  /// 필터가 적용되었는지 여부
  bool get isFiltered => selectedDifficulty != null || selectedType != null;

  /// 추천팩 필터가 적용되었는지 여부
  bool get isRecommendedPackFiltered => selectedRecommendedPackTypes.isNotEmpty;

  /// 현재 적용된 필터 텍스트
  String? get appliedFilterText {
    if (selectedDifficulty != null) {
      return '난이도: ${selectedDifficulty!.name}';
    }
    if (selectedType != null) {
      return '타입: $selectedType';
    }
    return null;
  }
}

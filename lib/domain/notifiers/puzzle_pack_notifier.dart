import 'package:chessudoku/core/base/base_notifier.dart';
import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/intents/puzzle_pack_intent.dart';
import 'package:chessudoku/domain/repositories/puzzle_pack_repository.dart';
import 'package:chessudoku/domain/states/puzzle_pack_state.dart';

class PuzzlePackNotifier
    extends BaseNotifier<PuzzlePackIntent, PuzzlePackState> {
  final PuzzlePackRepository _repository;

  PuzzlePackNotifier({required PuzzlePackRepository repository})
      : _repository = repository,
        super(const PuzzlePackState());

  @override
  void onIntent(PuzzlePackIntent intent) {
    switch (intent) {
      case LoadAllPuzzlePacksIntent():
        _loadAllPuzzlePacks();
        break;
      case LoadPuzzlePacksByDifficultyIntent(:final difficulty):
        _loadPuzzlePacksByDifficulty(difficulty);
        break;
      case LoadPuzzlePacksByTypeIntent(:final type):
        _loadPuzzlePacksByType(type);
        break;
      case LoadRecommendedPuzzlePacksIntent():
        _loadRecommendedPuzzlePacks();
        break;
      case InitializeRecommendedPackFilterIntent():
        _initializeRecommendedPackFilter();
        break;
      case ToggleRecommendedPackTypeFilterIntent(:final type):
        _toggleRecommendedPackTypeFilter(type);
        break;
      case ToggleAllRecommendedPackFilterIntent():
        _toggleAllRecommendedPackFilter();
        break;
      case LoadPremiumPuzzlePacksIntent():
        _loadPremiumPuzzlePacks();
        break;
      case UpdatePuzzlePackProgressIntent(
          :final packId,
          :final completedPuzzles
        ):
        _updatePuzzlePackProgress(packId, completedPuzzles);
        break;
      case RefreshPuzzlePacksIntent():
        _refreshPuzzlePacks();
        break;
    }
  }

  Future<void> _loadAllPuzzlePacks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final puzzlePacks = await _repository.getAllPuzzlePacks();
      state = state.copyWith(
        puzzlePacks: puzzlePacks,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> _loadPuzzlePacksByDifficulty(Difficulty difficulty) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final puzzlePacks =
          await _repository.getPuzzlePacksByDifficulty(difficulty);
      state = state.copyWith(
        puzzlePacks: puzzlePacks,
        isLoading: false,
        selectedDifficulty: difficulty,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> _loadPuzzlePacksByType(String type) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final puzzlePacks = await _repository.getPuzzlePacksByType(type);
      state = state.copyWith(
        puzzlePacks: puzzlePacks,
        isLoading: false,
        selectedType: type,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> _loadRecommendedPuzzlePacks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final puzzlePacks = await _repository.getRecommendedPuzzlePacks();
      state = state.copyWith(
        recommendedPacks: puzzlePacks,
        filteredRecommendedPacks: puzzlePacks,
        isLoading: false,
      );

      // 필터 초기화
      _initializeRecommendedPackFilter();
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  void _initializeRecommendedPackFilter() {
    if (state.recommendedPacks.isEmpty) return;

    // 모든 타입 수집
    final allTypes = <String>{};
    for (final pack in state.recommendedPacks) {
      allTypes.addAll(pack.type);
    }

    // 필터 옵션 생성
    final filterOptions = allTypes
        .map((type) => FilterOption<String>(
              id: type,
              label: type,
              value: type,
              isSelected: false,
            ))
        .toList();

    state = state.copyWith(
      recommendedPackFilterOptions: filterOptions,
      selectedRecommendedPackTypes: [],
      filteredRecommendedPacks: state.recommendedPacks,
    );
  }

  void _toggleRecommendedPackTypeFilter(String type) {
    final selectedTypes = List<String>.from(state.selectedRecommendedPackTypes);
    final filterOptions =
        List<FilterOption<String>>.from(state.recommendedPackFilterOptions);

    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }

    // 필터 옵션 업데이트
    for (int i = 0; i < filterOptions.length; i++) {
      if (filterOptions[i].value == type) {
        filterOptions[i] = filterOptions[i].copyWith(
          isSelected: selectedTypes.contains(type),
        );
        break;
      }
    }

    // 필터링된 팩 목록 생성
    final filteredPacks = _getFilteredRecommendedPacks(selectedTypes);

    state = state.copyWith(
      selectedRecommendedPackTypes: selectedTypes,
      recommendedPackFilterOptions: filterOptions,
      filteredRecommendedPacks: filteredPacks,
    );
  }

  void _toggleAllRecommendedPackFilter() {
    final bool isAllSelected = state.selectedRecommendedPackTypes.isNotEmpty;
    final filterOptions =
        List<FilterOption<String>>.from(state.recommendedPackFilterOptions);

    if (isAllSelected) {
      // 모든 필터 해제
      for (int i = 0; i < filterOptions.length; i++) {
        filterOptions[i] = filterOptions[i].copyWith(isSelected: false);
      }

      state = state.copyWith(
        selectedRecommendedPackTypes: [],
        recommendedPackFilterOptions: filterOptions,
        filteredRecommendedPacks: state.recommendedPacks,
      );
    } else {
      // 모든 필터 선택
      final allTypes = filterOptions.map((option) => option.value).toList();

      for (int i = 0; i < filterOptions.length; i++) {
        filterOptions[i] = filterOptions[i].copyWith(isSelected: true);
      }

      final filteredPacks = _getFilteredRecommendedPacks(allTypes);

      state = state.copyWith(
        selectedRecommendedPackTypes: allTypes,
        recommendedPackFilterOptions: filterOptions,
        filteredRecommendedPacks: filteredPacks,
      );
    }
  }

  List<PuzzlePack> _getFilteredRecommendedPacks(List<String> selectedTypes) {
    if (selectedTypes.isEmpty) {
      return state.recommendedPacks;
    }

    return state.recommendedPacks.where((pack) {
      return pack.type.any((type) => selectedTypes.contains(type));
    }).toList();
  }

  Future<void> _loadPremiumPuzzlePacks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final puzzlePacks = await _repository.getPremiumPuzzlePacks();
      state = state.copyWith(
        premiumPacks: puzzlePacks,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> _updatePuzzlePackProgress(
      String packId, int completedPuzzles) async {
    try {
      await _repository.updatePuzzlePackProgress(packId, completedPuzzles);

      // 상태 업데이트를 위해 현재 퍼즐팩 목록 다시 로드
      await _refreshPuzzlePacks();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> _refreshPuzzlePacks() async {
    // 현재 선택된 필터에 따라 데이터 새로고침
    if (state.selectedDifficulty != null) {
      await _loadPuzzlePacksByDifficulty(state.selectedDifficulty!);
    } else if (state.selectedType != null) {
      await _loadPuzzlePacksByType(state.selectedType!);
    } else {
      await _loadAllPuzzlePacks();
    }

    // 추천팩과 프리미엄팩도 함께 새로고침
    await _loadRecommendedPuzzlePacks();
    await _loadPremiumPuzzlePacks();
  }
}

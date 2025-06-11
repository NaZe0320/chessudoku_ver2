import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/enums/filter_type.dart';
import 'package:chessudoku/domain/intents/filter_intent.dart';
import 'package:chessudoku/core/di/puzzle_pack_provider.dart';
import 'package:chessudoku/ui/screens/pack/widgets/puzzle_pack_card.dart';
import 'package:chessudoku/ui/common/widgets/filter_chip/filter_chip_group.dart';

class RecommendPackTabContent extends HookConsumerWidget {
  const RecommendPackTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void initializeFilter() {
      // 모든 타입 수집
      final allTypes = <String>{};
      for (final pack in _samplePacks) {
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

      // 필터 옵션 설정
      ref.read(recommendPackTypeFilterProvider.notifier).handleIntent(
            SetFilterOptionsIntent<String>(
              options: filterOptions,
              filterType: FilterType.single,
              showAllOption: true,
            ),
          );
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializeFilter();
      });
      return null;
    }, []);

    List<PuzzlePack> getFilteredPacks() {
      final filterState = ref.watch(recommendPackTypeFilterProvider);

      // 전체 선택이거나 선택된 필터가 없으면 모든 팩 반환
      if (filterState.isAllSelected || filterState.selectedValues.isEmpty) {
        return _samplePacks;
      }

      // 선택된 타입과 일치하는 팩들만 필터링
      return _samplePacks.where((pack) {
        return pack.type
            .any((type) => filterState.selectedValues.contains(type));
      }).toList();
    }

    final filteredPacks = getFilteredPacks();

    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '추천 팩',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 필터 칩 그룹 추가
          FilterChipGroup<String>(
            provider: recommendPackTypeFilterProvider,
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          // 필터링된 팩 목록
          if (filteredPacks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '해당 조건에 맞는 팩이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 12, // 가로 간격
              runSpacing: 12, // 세로 간격
              children: filteredPacks.map((pack) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 44) /
                      2, // 전체 너비에서 패딩과 간격을 빼고 2로 나눔
                  child: PuzzlePackCard(
                    pack: pack,
                    onTap: () {
                      // TODO: 팩 상세 화면으로 이동
                      debugPrint('팩 선택: ${pack.name}');
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// 샘플 퍼즐팩 데이터
  static const List<PuzzlePack> _samplePacks = [
    PuzzlePack(
      id: '1',
      name: '체스 마스터',
      totalPuzzles: 30,
      difficulty: Difficulty.easy,
      type: ['체스'],
      iconAsset: '',
      completedPuzzles: 0,
    ),
    PuzzlePack(
      id: '2',
      name: '나이트 투어',
      totalPuzzles: 15,
      difficulty: Difficulty.medium,
      type: ['추천'],
      isPremium: true,
      iconAsset: '',
      completedPuzzles: 0,
    ),
    PuzzlePack(
      id: '3',
      name: '초보자용',
      totalPuzzles: 10,
      difficulty: Difficulty.easy,
      type: ['초보자'],
      iconAsset: '',
      completedPuzzles: 0,
    ),
    PuzzlePack(
      id: '4',
      name: '킹 어택',
      totalPuzzles: 20,
      difficulty: Difficulty.expert,
      type: ['고급'],
      isPremium: true,
      iconAsset: '',
      completedPuzzles: 0,
    ),
    PuzzlePack(
      id: '5',
      name: '킹 디펜스',
      totalPuzzles: 25,
      difficulty: Difficulty.medium,
      type: ['고급', '인기'],
      isPremium: true,
      iconAsset: '',
      completedPuzzles: 0,
    ),
    PuzzlePack(
      id: '6',
      name: '비숍 챌린지',
      totalPuzzles: 18,
      difficulty: Difficulty.expert,
      type: ['고급', '인기'],
      isPremium: true,
      iconAsset: '',
      completedPuzzles: 0,
    ),
  ];
}

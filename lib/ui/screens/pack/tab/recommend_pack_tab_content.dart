import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/filter_type.dart';
import 'package:chessudoku/domain/intents/filter_intent.dart';
import 'package:chessudoku/core/di/puzzle_pack_provider.dart';
import 'package:chessudoku/ui/screens/pack/widgets/puzzle_pack_card.dart';
import 'package:chessudoku/ui/common/widgets/filter_chip/filter_chip_group.dart';

class RecommendPackTabContent extends HookConsumerWidget {
  const RecommendPackTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzlePackState = ref.watch(puzzlePackNotifierProvider);
    final puzzlePackNotifier = ref.read(puzzlePackNotifierProvider.notifier);

    // 컴포넌트가 마운트될 때 데이터 로드
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        puzzlePackNotifier.loadPuzzlePacks();
      });
      return null;
    }, []);

    // 퍼즐 팩 데이터가 로드되면 필터 옵션 설정
    useEffect(() {
      if (puzzlePackState.puzzlePacks.isNotEmpty) {
        final allTypes = <String>{};
        for (final pack in puzzlePackState.puzzlePacks) {
          allTypes.addAll(pack.type);
        }

        final filterOptions = allTypes
            .map((type) => FilterOption<String>(
                  id: type,
                  label: type,
                  value: type,
                  isSelected: false,
                ))
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(recommendPackTypeFilterProvider.notifier).handleIntent(
                SetFilterOptionsIntent<String>(
                  options: filterOptions,
                  filterType: FilterType.single,
                  showAllOption: true,
                ),
              );
        });
      }
      return null;
    }, [puzzlePackState.puzzlePacks]);

    // 에러 상태 처리
    if (puzzlePackState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '데이터를 불러오는 중 오류가 발생했습니다',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              puzzlePackState.errorMessage!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => puzzlePackNotifier.loadPuzzlePacks(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 로딩 상태 처리
    if (puzzlePackState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 데이터 표시
    final filterState = ref.watch(recommendPackTypeFilterProvider);
    final filteredPacks =
        (filterState.isAllSelected || filterState.selectedValues.isEmpty)
            ? puzzlePackState.puzzlePacks
            : puzzlePackState.puzzlePacks.where((pack) {
                return pack.type
                    .any((type) => filterState.selectedValues.contains(type));
              }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '추천 팩',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FilterChipGroup<String>(
            provider: recommendPackTypeFilterProvider,
          ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: filteredPacks.map((pack) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 44) / 2,
                    child: PuzzlePackCard(
                      pack: pack,
                      onTap: () {
                        debugPrint('팩 선택: ${pack.name}');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/enums/filter_type.dart';
import 'package:chessudoku/domain/intents/filter_intent.dart';
import 'package:chessudoku/core/di/puzzle_pack_provider.dart';
import 'package:chessudoku/ui/screens/pack/widgets/puzzle_pack_card.dart';
import 'package:chessudoku/ui/common/widgets/filter_chip/filter_chip_group.dart';
import 'package:chessudoku/core/di/puzzle_providers.dart';

class RecommendPackTabContent extends HookConsumerWidget {
  const RecommendPackTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzlePacksAsync = ref.watch(puzzlePackListProvider);

    useEffect(() {
      if (puzzlePacksAsync is AsyncData<List<PuzzlePack>>) {
        final allTypes = <String>{};
        for (final pack in puzzlePacksAsync.value) {
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
    }, [puzzlePacksAsync]);

    return puzzlePacksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (packs) {
        final filterState = ref.watch(recommendPackTypeFilterProvider);
        final filteredPacks = (filterState.isAllSelected ||
                filterState.selectedValues.isEmpty)
            ? packs
            : packs.where((pack) {
                return pack.type
                    .any((type) => filterState.selectedValues.contains(type));
              }).toList();

        return SingleChildScrollView(
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
              FilterChipGroup<String>(
                provider: recommendPackTypeFilterProvider,
                padding: const EdgeInsets.only(bottom: 16.0),
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
                Wrap(
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
            ],
          ),
        );
      },
    );
  }
}

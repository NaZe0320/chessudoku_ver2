import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/data/models/filter_option.dart';
import 'package:chessudoku/domain/intents/puzzle_pack_intent.dart';
import 'package:chessudoku/core/di/puzzle_pack_provider.dart';
import 'package:chessudoku/ui/screens/pack/widgets/puzzle_pack_card.dart';
import 'package:chessudoku/ui/common/widgets/filter_chip/filter_chip_widget.dart';

class RecommendPackTabContent extends ConsumerStatefulWidget {
  const RecommendPackTabContent({super.key});

  @override
  ConsumerState<RecommendPackTabContent> createState() =>
      _RecommendPackTabContentState();
}

class _RecommendPackTabContentState
    extends ConsumerState<RecommendPackTabContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendedPacks();
    });
  }

  void _loadRecommendedPacks() {
    // 추천 퍼즐팩 데이터 로드
    final notifier = ref.read(puzzlePackNotifierProvider.notifier);
    notifier.handleIntent(LoadRecommendedPuzzlePacksIntent());
  }

  @override
  Widget build(BuildContext context) {
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
          Consumer(
            builder: (context, ref, child) {
              final puzzlePackState = ref.watch(puzzlePackNotifierProvider);

              // 로딩 상태
              if (puzzlePackState.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // 에러 상태
              if (puzzlePackState.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '데이터를 불러올 수 없습니다\n${puzzlePackState.error}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _loadRecommendedPacks();
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filteredPacks = puzzlePackState.filteredRecommendedPacks;
              final filterOptions =
                  puzzlePackState.recommendedPackFilterOptions;

              return Column(
                children: [
                  // 필터 칩 그룹
                  if (filterOptions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // 전체 선택/해제 칩
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChipWidget(
                                option: FilterOption<String>(
                                  id: 'all',
                                  label: '전체',
                                  value: 'all',
                                  isSelected: puzzlePackState
                                      .selectedRecommendedPackTypes.isEmpty,
                                ),
                                onTap: () {
                                  final notifier = ref.read(
                                      puzzlePackNotifierProvider.notifier);
                                  notifier.handleIntent(
                                      ToggleAllRecommendedPackFilterIntent());
                                },
                              ),
                            ),
                            // 타입별 필터 칩들
                            ...filterOptions
                                .map((option) => Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: FilterChipWidget(
                                        option: option,
                                        onTap: () {
                                          final notifier = ref.read(
                                              puzzlePackNotifierProvider
                                                  .notifier);
                                          notifier.handleIntent(
                                              ToggleRecommendedPackTypeFilterIntent(
                                                  type: option.value));
                                        },
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
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
                              debugPrint('팩 선택: ${pack.name}');

                              // 예시: 진행률 업데이트 테스트
                              final notifier =
                                  ref.read(puzzlePackNotifierProvider.notifier);
                              notifier
                                  .handleIntent(UpdatePuzzlePackProgressIntent(
                                packId: pack.id,
                                completedPuzzles: pack.completedPuzzles + 1,
                              ));
                            },
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

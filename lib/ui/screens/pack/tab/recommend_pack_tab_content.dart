import 'package:flutter/material.dart';
import 'package:chessudoku/data/models/puzzle_pack.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/screens/pack/widgets/puzzle_pack_card.dart';

class RecommendPackTabContent extends StatelessWidget {
  const RecommendPackTabContent({super.key});

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
          Wrap(
            spacing: 12, // 가로 간격
            runSpacing: 12, // 세로 간격
            children: _samplePacks.map((pack) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) /
                    2, // 전체 너비에서 패딩과 간격을 빼고 2로 나눔
                child: PuzzlePackCard(
                  pack: pack,
                  onTap: () {
                    // TODO: 팩 상세 화면으로 이동
                    print('팩 선택: ${pack.name}');
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

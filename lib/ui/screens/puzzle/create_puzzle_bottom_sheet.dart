import 'package:flutter/material.dart';

void showCreatePuzzleBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const CreatePuzzleBottomSheet(),
  );
}

class CreatePuzzleBottomSheet extends StatefulWidget {
  const CreatePuzzleBottomSheet({super.key});

  @override
  State<CreatePuzzleBottomSheet> createState() =>
      _CreatePuzzleBottomSheetState();
}

class _CreatePuzzleBottomSheetState extends State<CreatePuzzleBottomSheet> {
  int selectedDifficulty = 0; // 0: 쉬움, 1: 보통, 2: 어려움, 3: 전문가

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 타이틀 및 닫기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('퍼즐 생성하기',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 난이도 선택
          Row(
            children: [
              _difficultyButton('쉬움', '체스 기물 1-2개', 0),
              const SizedBox(width: 8),
              _difficultyButton('보통', '체스 기물 3-5개', 1),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _difficultyButton('어려움', '체스 기물 5-8개', 2),
              const SizedBox(width: 8),
              _difficultyButton('전문가', '복잡한 기물 조합', 3, isPremium: true),
            ],
          ),
          const SizedBox(height: 24),
          // 상세 설정 (비활성화)
          Opacity(
            opacity: 0.5,
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('프리미엄 가입 후 이용 가능합니다',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('프리미엄으로 업그레이드'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 하단 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('퍼즐 생성하기'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _difficultyButton(String title, String subtitle, int index,
      {bool isPremium = false}) {
    final isSelected = selectedDifficulty == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDifficulty = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.grey[100],
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              if (isPremium)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('프리미엄',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/core/di/puzzle_providers.dart';
import 'package:chessudoku/domain/enums/creation_status.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/domain/intents/puzzle_creation_intent.dart';
import 'package:chessudoku/domain/states/puzzle_creation_state.dart';
import 'package:chessudoku/ui/screens/puzzle/puzzle_screen.dart';

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

class CreatePuzzleBottomSheet extends ConsumerStatefulWidget {
  const CreatePuzzleBottomSheet({super.key});

  @override
  ConsumerState<CreatePuzzleBottomSheet> createState() =>
      _CreatePuzzleBottomSheetState();
}

class _CreatePuzzleBottomSheetState
    extends ConsumerState<CreatePuzzleBottomSheet> {
  Difficulty selectedDifficulty = Difficulty.easy;
  bool isCreating = false;

  @override
  Widget build(BuildContext context) {
    // 퍼즐 생성 상태 구독
    final puzzleCreationState = ref.watch(puzzleCreationProvider);

    // 상태에 따른 UI 업데이트
    _handlePuzzleCreationState(puzzleCreationState);

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
              _difficultyButton('쉬움', '체스 기물 1-2개', Difficulty.easy),
              const SizedBox(width: 8),
              _difficultyButton('보통', '체스 기물 3-5개', Difficulty.medium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _difficultyButton('어려움', '체스 기물 5-8개', Difficulty.hard),
              const SizedBox(width: 8),
              // 전문가 난이도는 아직 구현되지 않아 비활성화
              _premiumDifficultyButton('전문가', '복잡한 기물 조합'),
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
                  onPressed: isCreating ? null : () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isCreating ? null : _createPuzzle,
                  child: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('퍼즐 생성하기'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _difficultyButton(
      String title, String subtitle, Difficulty difficulty) {
    final isSelected = selectedDifficulty == difficulty;
    return Expanded(
      child: GestureDetector(
        onTap: isCreating
            ? null
            : () {
                setState(() {
                  selectedDifficulty = difficulty;
                });

                // 난이도 선택 인텐트 전송
                ref
                    .read(puzzleCreationProvider.notifier)
                    .onIntent(SelectDifficultyIntent(difficulty));
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumDifficultyButton(String title, String subtitle) {
    return Expanded(
      child: Opacity(
        opacity: 0.5, // 비활성화 효과를 위한 투명도 조절
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ),
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
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              // 자물쇠 아이콘 추가
              const Positioned(
                right: 0,
                bottom: 0,
                child: Icon(Icons.lock, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createPuzzle() {
    setState(() {
      isCreating = true;
    });

    // 퍼즐 생성 인텐트 전송
    ref
        .read(puzzleCreationProvider.notifier)
        .onIntent(CreatePuzzleIntent(selectedDifficulty));
  }

  void _handlePuzzleCreationState(PuzzleCreationState state) {
    if (state.status == CreationStatus.loading) {
      setState(() {
        isCreating = true;
      });
    } else if (state.status == CreationStatus.success && isCreating) {
      setState(() {
        isCreating = false;
      });
      // 퍼즐 생성 성공 시 화면 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context); // 바텀시트 닫기
        if (state.generatedBoard != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PuzzleScreen(board: state.generatedBoard!),
            ),
          );
        }
      });
    } else if (state.status == CreationStatus.failure && isCreating) {
      setState(() {
        isCreating = false;
      });
      // 오류 메시지 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('퍼즐 생성 실패: ${state.errorMessage ?? '알 수 없는 오류'}')),
        );
      });
    }
  }
}

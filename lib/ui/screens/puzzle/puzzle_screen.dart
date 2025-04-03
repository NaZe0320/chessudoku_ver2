import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_board.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_controls.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_header.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/puzzle_keypad.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:chessudoku/ui/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  @override
  void initState() {
    super.initState();

    // 화면이 처음 열릴 때 게임 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(puzzleIntentProvider).initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(puzzleProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title:
            const Text('체스도쿠', style: TextStyle(color: AppColors.neutral100)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral100),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 타이머 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer,
                        size: 18, color: AppColors.neutral100),
                    const SizedBox(width: 4),
                    Text(
                      puzzleState.formattedTime,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            // 헤더 - 난이도 및 완료 메시지
            PuzzleHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 16,
                    children: [
                      PuzzleBoard(),
                    // 난이도 선택 및 게임 제어 버튼
                    PuzzleControls(),
                    // 숫자 키패드
                    PuzzleKeypad(),
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}

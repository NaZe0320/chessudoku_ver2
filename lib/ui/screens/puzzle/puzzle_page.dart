import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/continue_game_dialog.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/loading_dialog.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzlePage extends ConsumerWidget {
  const PuzzlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.read(puzzleIntentProvider);

    // 난이도별 게임 시작 핸들러
    Future<void> handleStartGame(Difficulty difficulty) async {
      // 난이도 변경
      intent.changeDifficulty(difficulty);

      // 선택한 난이도의 저장된 게임이 있는지 확인
      final hasSavedGame = intent.hasSavedGame(difficulty);

      if (hasSavedGame) {
        // 저장된 게임이 있으면 다이얼로그 표시
        final shouldContinue =
            await ContinueGameDialog.show(context, difficulty);

        if (shouldContinue == true) {
          // 이어하기 선택 - 저장된 데이터 사용
          // 이어하기는 PuzzleScreen에서 자동으로 처리됨
          LoadingDialog.show(context, message: '게임을 불러오는 중...');
          await Future.delayed(
              const Duration(milliseconds: 300)); // UI 업데이트를 위한 지연
          LoadingDialog.hide(context);
          AppRoutes.navigateToPuzzleScreen(context, difficulty);
        } else if (shouldContinue == false) {
          // 새로 시작 선택 - 저장된 데이터 삭제 후 시작
          LoadingDialog.show(context, message: '새 게임을 준비하는 중...');
          await intent.clearSavedGameState(difficulty);

          // 퍼즐 생성 및 게임 초기화 (PuzzleScreen으로 이동하기 전)
          await intent.initializeGame();
          LoadingDialog.hide(context);
          AppRoutes.navigateToPuzzleScreen(context, difficulty);
        }
        // shouldContinue가 null이면 취소된 것이므로 아무 동작 없음
      } else {
        // 저장된 게임이 없으면 퍼즐 생성 후 게임 화면으로 이동
        LoadingDialog.show(context, message: '퍼즐을 생성하는 중...');
        await intent.initializeGame(); // 퍼즐 생성 및 게임 초기화
        LoadingDialog.hide(context);
        AppRoutes.navigateToPuzzleScreen(context, difficulty);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '체스도쿠',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight.withAlpha(77),
              AppColors.neutral100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/logo.png', // 로고 이미지가 있다고 가정
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.extension,
                      size: 80,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  '난이도를 선택하세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 40),
                _buildDifficultyButton(
                  context: context,
                  difficulty: Difficulty.easy,
                  icon: Icons.sentiment_satisfied_alt,
                  onPressed: () => handleStartGame(Difficulty.easy),
                ),
                const SizedBox(height: 16),
                _buildDifficultyButton(
                  context: context,
                  difficulty: Difficulty.medium,
                  icon: Icons.sentiment_neutral,
                  onPressed: () => handleStartGame(Difficulty.medium),
                ),
                const SizedBox(height: 16),
                _buildDifficultyButton(
                  context: context,
                  difficulty: Difficulty.hard,
                  icon: Icons.sentiment_very_dissatisfied,
                  onPressed: () => handleStartGame(Difficulty.hard),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppRoutes.navigateToRecordsPage(context);
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('기록실'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required BuildContext context,
    required Difficulty difficulty,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    String difficultyText;
    Color buttonColor;

    switch (difficulty) {
      case Difficulty.easy:
        difficultyText = '쉬움';
        buttonColor = AppColors.success;
        break;
      case Difficulty.medium:
        difficultyText = '보통';
        buttonColor = AppColors.warning;
        break;
      case Difficulty.hard:
        difficultyText = '어려움';
        buttonColor = AppColors.error;
        break;
    }

    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 10),
            Text(
              difficultyText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

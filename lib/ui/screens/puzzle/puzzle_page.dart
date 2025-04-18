import 'package:chessudoku/core/di/puzzle_provider.dart';
import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/continue_game_dialog.dart';

import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final intent =
        ProviderScope.containerOf(context).read(puzzleIntentProvider);

    // 난이도별 게임 시작 핸들러
    Future<void> handleStartGame(Difficulty difficulty) async {
      if (!context.mounted) return;
      final navigationContext = context;

      final shouldNavigate = await intent.handleStartGame(difficulty);

      if (shouldNavigate == null && navigationContext.mounted) {
        // 저장된 게임이 있는 경우 다이얼로그 표시
        final shouldContinue =
            await ContinueGameDialog.show(navigationContext, difficulty);

        if (shouldContinue != null) {
          if (!navigationContext.mounted) return;
          await intent.continueOrStartNewGame(difficulty, shouldContinue);
          if (!navigationContext.mounted) return;
          AppRoutes.navigateToPuzzleScreen(navigationContext, difficulty);
        }
        // shouldContinue가 null이면 취소된 것이므로 아무 동작 없음
      } else if (shouldNavigate == true && navigationContext.mounted) {
        // 새 게임 시작 또는 이어하기
        AppRoutes.navigateToPuzzleScreen(navigationContext, difficulty);
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

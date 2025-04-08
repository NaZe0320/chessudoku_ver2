import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/continue_game_dialog.dart';
import 'package:chessudoku/ui/screens/puzzle/widgets/loading_dialog.dart';
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
      appBar: AppBar(title: const Text('퍼즐')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => handleStartGame(Difficulty.easy),
              child: const Text('쉬움'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleStartGame(Difficulty.medium),
              child: const Text('보통'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleStartGame(Difficulty.hard),
              child: const Text('어려움'),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () {
                AppRoutes.navigateToRecordsPage(context);
              },
              icon: const Icon(Icons.history),
              label: const Text('기록실'),
            ),
          ],
        ),
      ),
    );
  }
}

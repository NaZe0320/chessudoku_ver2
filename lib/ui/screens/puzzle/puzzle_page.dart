import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzlePage extends ConsumerWidget {
  const PuzzlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.read(puzzleIntentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('퍼즐')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                intent.changeDifficulty(Difficulty.easy);
                AppRoutes.navigateToPuzzleScreen(context, Difficulty.easy);
              },
              child: const Text('쉬움'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                intent.changeDifficulty(Difficulty.medium);
                AppRoutes.navigateToPuzzleScreen(context, Difficulty.medium);
              },
              child: const Text('보통'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                intent.changeDifficulty(Difficulty.hard);
                AppRoutes.navigateToPuzzleScreen(context, Difficulty.hard);
              },
              child: const Text('어려움'),
            ),
          ],
        ),
      ),
    );
  }
}

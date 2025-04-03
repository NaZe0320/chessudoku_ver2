import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/screens/puzzle/puzzle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzlePage extends ConsumerWidget {
  const PuzzlePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('퍼즐')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ref
                    .read(puzzleProvider.notifier)
                    .changeDifficulty(Difficulty.easy);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PuzzleScreen()));
              },
              child: const Text('쉬움'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(puzzleProvider.notifier)
                    .changeDifficulty(Difficulty.medium);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PuzzleScreen()));
              },
              child: const Text('보통'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(puzzleProvider.notifier)
                    .changeDifficulty(Difficulty.hard);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PuzzleScreen()));
              },
              child: const Text('어려움'),
            ),
          ],
        ),
      ),
    );
  }
}

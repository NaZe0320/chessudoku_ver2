import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';

class GameTimer extends HookConsumerWidget {
  const GameTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    // 초를 MM:SS 형태로 변환
    String formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: Colors.grey[700],
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            formatTime(gameState.elapsedSeconds),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              if (gameState.isTimerRunning) {
                gameNotifier.handleIntent(const PauseTimerIntent());
              } else {
                gameNotifier.handleIntent(const StartTimerIntent());
              }
            },
            child: Icon(
              gameState.isTimerRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.grey[700],
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

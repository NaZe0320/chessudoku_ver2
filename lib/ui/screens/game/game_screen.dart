import 'package:chessudoku/ui/screens/game/widgets/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'widgets/game_timer.dart';
import 'widgets/game_action_buttons.dart';
import 'widgets/number_buttons_grid.dart';

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    // 화면 진입 시 타이머 시작
    useEffect(() {
      Future(() {
        gameNotifier.handleIntent(const StartTimerIntent());
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: Text(translate('game_screen', '게임')),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const GameTimer(),
                const Expanded(child: SudokuBoard()),
                const GameActionButtons(),
                const SizedBox(height: 16),
                NumberButtonsGrid(
                  selectedNumbers: gameState.selectedNumbers,
                  onNumberTap: (number) {
                    gameNotifier.handleIntent(SelectNumberIntent(number));
                  },
                  onClearTap: () {
                    gameNotifier.handleIntent(const ClearSelectionIntent());
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

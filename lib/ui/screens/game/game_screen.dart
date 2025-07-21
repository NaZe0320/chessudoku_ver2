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
import 'widgets/game_completion_dialog.dart';

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    // 화면 진입 시 타이머 시작 및 테스트 보드 초기화
    useEffect(() {
      Future(() {
        gameNotifier.handleIntent(const StartTimerIntent());

        // 테스트용 완성된 보드 초기화 (임시)
        if (gameState.currentBoard == null) {
          gameNotifier.handleIntent(const InitializeTestBoardIntent());
        }
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
      body: Stack(
        children: [
          Container(
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
                      isNoteMode: gameState.currentBoard?.isNoteMode ?? false,
                      selectedCellNotes:
                          gameState.currentBoard?.selectedCellNotes,
                      onNumberTap: (number) {
                        // 숫자 입력 기능으로 변경
                        gameNotifier.handleIntent(InputNumberIntent(number));
                      },
                      onClearTap: () {
                        // 셀 지우기 기능으로 변경
                        gameNotifier.handleIntent(const ClearCellIntent());
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // 게임 완료 다이얼로그 오버레이
          if (gameState.showCompletionDialog)
            Container(
              color: Colors.black54,
              child: Center(
                child: GameCompletionDialog(
                  elapsedSeconds: gameState.elapsedSeconds,
                  onNewGame: () {
                    // 새 게임 시작 로직
                    gameNotifier
                        .handleIntent(const InitializeTestBoardIntent());
                    gameNotifier.handleIntent(const StartTimerIntent());
                  },
                  onContinue: () {
                    // 계속하기 - 다이얼로그만 닫기
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

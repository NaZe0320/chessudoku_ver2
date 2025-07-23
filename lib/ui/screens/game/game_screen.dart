import 'package:chessudoku/ui/screens/game/widgets/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/common/widgets/exit_game_dialog.dart';
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

    // 화면 진입 시 저장된 게임 로드 및 초기화
    useEffect(() {
      Future(() async {
        // 저장된 게임 로드 시도
        await gameNotifier.loadSavedGame();

        // 로드 후 현재 상태 확인
        final currentState = ref.read(gameNotifierProvider);

        // 저장된 게임이 없거나 완료된 경우에만 새 게임 시작
        if (currentState.currentBoard == null || currentState.isGameCompleted) {
          gameNotifier.handleIntent(const InitializeTestBoardIntent());
          // 새 게임인 경우 타이머 시작
          gameNotifier.handleIntent(const StartTimerIntent());
        } else {
          // 기존 게임이 있고 완료되지 않은 경우 타이머 시작
          if (!currentState.isGameCompleted && currentState.isPaused) {
            gameNotifier.handleIntent(const StartTimerIntent());
          }
        }
      });
      return null;
    }, []);

    return WillPopScope(
        onWillPop: () async {
          // 게임이 완료되었거나 보드가 없는 경우 바로 나가기
          if (gameState.isGameCompleted || gameState.currentBoard == null) {
            return true;
          }

          // 중단 확인 다이얼로그 표시
          final shouldExit = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return ExitGameDialog(
                title: translate('exit_game_title', '게임 중단'),
                message: translate(
                    'exit_game_message', '게임을 중단하시겠습니까?\n진행 상황이 저장됩니다.'),
                cancelText: translate('cancel', '취소'),
                exitText: translate('exit', '중단'),
                onCancel: () => Navigator.of(context).pop(false),
                onExit: () => Navigator.of(context).pop(true),
              );
            },
          );

          if (shouldExit == true) {
            // 게임 저장 후 나가기
            await gameNotifier.autoSave();
            return true;
          }

          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            title: Text(translate('game_screen', '게임')),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                // 게임이 완료되었거나 보드가 없는 경우 바로 나가기
                if (gameState.isGameCompleted ||
                    gameState.currentBoard == null) {
                  Navigator.of(context).pop();
                  return;
                }

                // 중단 확인 다이얼로그 표시
                final shouldExit = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ExitGameDialog(
                      title: translate('exit_game_title', '게임 중단'),
                      message: translate(
                          'exit_game_message', '게임을 중단하시겠습니까?\n진행 상황이 저장됩니다.'),
                      cancelText: translate('cancel', '취소'),
                      exitText: translate('exit', '중단'),
                      onCancel: () => Navigator.of(context).pop(false),
                      onExit: () => Navigator.of(context).pop(true),
                    );
                  },
                );

                if (shouldExit == true) {
                  // 게임 저장 후 나가기
                  await gameNotifier.autoSave();
                  Navigator.of(context).pop();
                }
              },
            ),
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
                        // 일시 정지 상태일 때는 보드 대신 일시 정지 메시지 표시
                        if (gameState.isPaused && !gameState.isGameCompleted)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                gameNotifier
                                    .handleIntent(const StartTimerIntent());
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.pause_circle_outline,
                                        size: 48,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        translate(
                                            'game_paused', '게임이 일시정지되었습니다'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        translate(
                                            'tap_to_resume', '화면을 탭하여 계속하기'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const Expanded(child: SudokuBoard()),
                        const GameActionButtons(),
                        const SizedBox(height: 16),
                        NumberButtonsGrid(
                          selectedNumbers: gameState.selectedNumbers,
                          isNoteMode:
                              gameState.currentBoard?.isNoteMode ?? false,
                          selectedCellNotes:
                              gameState.currentBoard?.selectedCellNotes,
                          isPaused: gameState.isPaused,
                          onNumberTap: (number) {
                            // 숫자 입력 기능으로 변경
                            gameNotifier
                                .handleIntent(InputNumberIntent(number));
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
                      onContinue: () {
                        // 메인 화면으로 이동
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}

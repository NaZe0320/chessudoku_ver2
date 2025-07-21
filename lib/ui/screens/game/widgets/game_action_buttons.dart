import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/core/di/game_provider.dart';
import 'package:chessudoku/domain/intents/game_intent.dart';
import 'game_action_button.dart';
import 'checkpoint_button.dart';

class GameActionButtons extends HookConsumerWidget {
  const GameActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        GameActionButton(
          icon: Icons.undo,
          text: translate('undo', '되돌리기'),
          isActive: gameState.canUndo,
          buttonType: ButtonType.action,
          onTap: () {
            gameNotifier.handleIntent(const UndoIntent());
          },
        ),
        GameActionButton(
          icon: Icons.edit_note,
          text: translate('memo', '메모'),
          isActive: gameState.currentBoard?.isNoteMode ?? false,
          buttonType: ButtonType.toggle,
          onTap: () {
            gameNotifier.handleIntent(const ToggleNoteModeIntent());
          },
        ),
        GameActionButton(
          icon: Icons.redo,
          text: translate('redo', '다시 실행'),
          isActive: gameState.canRedo,
          buttonType: ButtonType.action,
          onTap: () {
            gameNotifier.handleIntent(const RedoIntent());
          },
        ),
        GameActionButton(
          icon: Icons.error_outline,
          text: translate('check_error', '오류 검사'),
          isActive: true,
          buttonType: ButtonType.action,
          onTap: () {
            gameNotifier.handleIntent(const CheckErrorsIntent());
          },
        ),
        const CheckpointButton(),
      ],
    );
  }
}

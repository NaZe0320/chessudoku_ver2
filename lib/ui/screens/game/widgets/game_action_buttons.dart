import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'game_action_button.dart';
import 'checkpoint_button.dart';

class GameActionButtons extends HookConsumerWidget {
  const GameActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        GameActionButton(
          icon: Icons.undo,
          text: translate('undo', '되돌리기'),
          onTap: () {
            // TODO: Intent로 처리 예정
          },
        ),
        GameActionButton(
          icon: Icons.edit_note,
          text: translate('memo', '메모'),
          onTap: () {
            // TODO: Intent로 처리 예정
          },
        ),
        GameActionButton(
          icon: Icons.redo,
          text: translate('redo', '다시 실행'),
          onTap: () {
            // TODO: Intent로 처리 예정
          },
        ),
        GameActionButton(
          icon: Icons.error_outline,
          text: translate('check_error', '오류 검사'),
          onTap: () {
            // TODO: Intent로 처리 예정
          },
        ),
        const CheckpointButton(),
      ],
    );
  }
}

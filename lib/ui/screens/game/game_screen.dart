import 'package:chessudoku/ui/screens/game/widgets/sudoku_board.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'widgets/game_timer.dart';

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: const SafeArea(
          child: Column(
            children: [
              GameTimer(),
              SudokuBoard(),
            ],
          ),
        ),
      ),
    );
  }
}

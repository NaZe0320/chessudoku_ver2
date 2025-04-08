import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleKeypad extends ConsumerWidget {
  const PuzzleKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzleState = ref.watch(puzzleProvider);

    return Column(
      children: [
        // 1-5 키패드
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final number = index + 1;
            bool isSelected = false;

            final selectedCell = puzzleState.selectedCell;
            if (selectedCell != null && selectedCell.number == number) {
              isSelected = true;
            }

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildNumberKey(
                number: number,
                onTap: () => _handleNumberPressed(number, ref),
                isSelected: isSelected,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // 6-9 키패드 및 지우기 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(4, (index) {
              final number = index + 6;
              bool isSelected = false;

              final selectedCell = puzzleState.selectedCell;
              if (selectedCell != null && selectedCell.number == number) {
                isSelected = true;
              }

              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildNumberKey(
                  number: number,
                  onTap: () => _handleNumberPressed(number, ref),
                  isSelected: isSelected,
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildClearKey(
                onTap: () => ref.read(puzzleIntentProvider).clearValue(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberKey({
    required int number,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.neutral200,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.neutral300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withAlpha(51)
                      : AppColors.neutral400.withAlpha(10),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color:
                      isSelected ? AppColors.neutral100 : AppColors.neutral800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearKey({
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withAlpha(204),
                  AppColors.error,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withAlpha(51),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.backspace_outlined,
                color: AppColors.neutral100,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 숫자 입력 처리
  void _handleNumberPressed(int number, WidgetRef ref) {
    final intent = ref.read(puzzleIntentProvider);
    final puzzleState = ref.read(puzzleProvider);

    // 메모 모드가 아니면서 이미 완성된 경우 무시
    if (!puzzleState.isNoteMode && puzzleState.isCompleted) {
      return;
    }

    // 숫자 입력 실행
    intent.enterNumber(number);
  }
}

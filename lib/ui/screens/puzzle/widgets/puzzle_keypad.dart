import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleKeypad extends ConsumerWidget {
  const PuzzleKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = ref.read(puzzleIntentProvider);
    final puzzleState = ref.watch(puzzleProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
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
                  onTap: () => intent.enterNumber(number),
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
                    onTap: () => intent.enterNumber(number),
                    isSelected: isSelected,
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: _buildClearKey(
                  onTap: () => intent.clearValue(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberKey({
    required int number,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primaryLight.withAlpha(10),
              shape: BoxShape.circle,
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: AppColors.neutral400.withAlpha(30),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
              ],
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.primary.withAlpha(30),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isSelected ? AppColors.neutral100 : AppColors.primary,
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
      width: 50,
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF44336), Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withAlpha(30),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

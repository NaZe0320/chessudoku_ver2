import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'number_button.dart';

class NumberButtonsGrid extends HookConsumerWidget {
  final Set<int> selectedNumbers;
  final Function(int) onNumberTap;
  final VoidCallback onClearTap;

  const NumberButtonsGrid({
    super.key,
    required this.selectedNumbers,
    required this.onNumberTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return Column(
      children: [
        // 첫 번째 줄: 1-5
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 1; i <= 5; i++) _buildNumberButton(i),
            ],
          ),
        ),
        // 두 번째 줄: 6-9, 취소 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 6; i <= 9; i++) _buildNumberButton(i),
            NumberButton(
              text: translate('clear', '취소'),
              icon: Icons.clear,
              onTap: onClearTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    return NumberButton(
      text: number.toString(),
      isSelected: selectedNumbers.contains(number),
      onTap: () => onNumberTap(number),
    );
  }
}

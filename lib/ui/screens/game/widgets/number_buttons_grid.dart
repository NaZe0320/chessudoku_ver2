import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'number_button.dart';

class NumberButtonsGrid extends HookConsumerWidget {
  final Set<int> selectedNumbers;
  final Function(int) onNumberTap;
  final VoidCallback onClearTap;
  final bool isNoteMode;
  final Set<int>? selectedCellNotes; // 선택된 셀의 메모 숫자들

  const NumberButtonsGrid({
    super.key,
    required this.selectedNumbers,
    required this.onNumberTap,
    required this.onClearTap,
    this.isNoteMode = false,
    this.selectedCellNotes,
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
    // 메모 모드일 때는 선택된 셀의 메모 숫자들도 고려
    final isSelected = selectedNumbers.contains(number) ||
        (isNoteMode && selectedCellNotes?.contains(number) == true);

    return NumberButton(
      text: number.toString(),
      isSelected: isSelected,
      onTap: () => onNumberTap(number),
    );
  }
}

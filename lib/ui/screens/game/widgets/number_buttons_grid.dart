import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'number_button.dart';

class NumberButtonsGrid extends HookConsumerWidget {
  final CellContent? selectedCellContent;
  final Function(int) onNumberTap;
  final VoidCallback onClearTap;
  final bool isNoteMode;
  final bool isPaused; // 일시정지 상태

  const NumberButtonsGrid({
    super.key,
    required this.selectedCellContent,
    required this.onNumberTap,
    required this.onClearTap,
    this.isNoteMode = false,
    this.isPaused = false,
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
              isDisabled: isPaused,
              onTap: isPaused ? null : onClearTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    // selectedCellContent에서 숫자나 메모 확인
    final isSelected = isNoteMode
        ? selectedCellContent?.notes.contains(number) == true
        : selectedCellContent?.number == number;

    return NumberButton(
      text: number.toString(),
      isSelected: isSelected,
      isDisabled: isPaused,
      onTap: isPaused ? null : () => onNumberTap(number),
    );
  }
}

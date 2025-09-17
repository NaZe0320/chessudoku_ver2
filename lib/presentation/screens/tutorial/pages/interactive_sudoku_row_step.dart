import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:flutter/material.dart';
// 튜토리얼 전용 경량 숫자 키패드 사용

class InteractiveSudokuRowStep extends StatefulWidget {
  const InteractiveSudokuRowStep(
      {super.key, required this.translate, required this.onCompleted});

  final String Function(String, String) translate;
  final VoidCallback onCompleted;

  @override
  State<InteractiveSudokuRowStep> createState() =>
      _InteractiveSudokuRowStepState();
}

class _InteractiveSudokuRowStepState extends State<InteractiveSudokuRowStep> {
  static const int _correctAnswer = 6;

  bool _solved = false;
  String? _feedback;

  void _handleNumberTap(int value) {
    if (_solved) return;
    if (value == _correctAnswer) {
      setState(() {
        _solved = true;
        _feedback =
            widget.translate('correct_answer', '정답이에요! 1-9가 모두 한 번씩 있습니다.');
      });
      widget.onCompleted();
    } else {
      setState(() {
        _feedback = widget.translate('try_again', '다시 시도해보세요. 빠진 숫자를 생각해보세요.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void showHintDialog() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(widget.translate('hint', '힌트')),
          content: Text(widget.translate(
              'sudoku_row_hint', '가로줄에는 1부터 9까지 모든 숫자가 한 번씩 등장합니다. 무엇이 빠졌나요?')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(widget.translate('ok', '확인')),
            )
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BoardPreviewRow(solved: _solved),
          const SizedBox(height: 12),
          _PromptBubble(
            text: widget.translate(
              'sudoku_row_prompt',
              '이 숫자 배열에서 빠진 숫자가 무엇인지 추측할 수 있나요?',
            ),
            onHint: showHintDialog,
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 8),
            Text(
              _feedback!,
              style: TextStyle(
                  color:
                      _solved ? Colors.lightGreenAccent : Colors.amberAccent),
            ),
          ],
          const Spacer(),
          _NumberKeypad(onTap: _handleNumberTap),
        ],
      ),
    );
  }
}

class _BoardPreviewRow extends StatelessWidget {
  const _BoardPreviewRow({required this.solved});
  final bool solved;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.15),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          children: List.generate(9, (row) {
            return Expanded(
              child: Row(
                children: List.generate(9, (col) {
                  final bool isTargetCell = row == 4 && col == 4;
                  final bool isTargetRow = row == 4;
                  final bool showNumberOnTargetRow = isTargetRow && col != 4;
                  final int? value = showNumberOnTargetRow
                      ? const [4, 3, 8, 5, null, 9, 7, 1, 2][col]
                      : null;
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isTargetRow
                            ? (isTargetCell
                                ? Colors.pinkAccent.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.06))
                            : Colors.transparent,
                        border: Border(
                          right: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1),
                          bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1),
                        ),
                      ),
                      child: Center(
                        child: value != null
                            ? Text(
                                '$value',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : (isTargetCell && solved)
                                ? const Text(
                                    '6',
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PromptBubble extends StatelessWidget {
  const _PromptBubble({required this.text, required this.onHint});
  final String text;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFB9F6CA).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🤔', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, height: 1.3),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onHint,
            child: const Text('Hint'),
          ),
        ],
      ),
    );
  }
}

class _NumberKeypad extends StatelessWidget {
  const _NumberKeypad({required this.onTap});
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final numbers = List<int>.generate(9, (i) => i + 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: numbers
            .map(
              (n) => GestureDetector(
                onTap: () => onTap(n),
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.pinkAccent.withValues(alpha: 0.6),
                        width: 2.5),
                  ),
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// 키패드는 게임 화면의 `NumberButtonsGrid`를 재사용합니다.

import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:chessudoku/ui/screens/game/widgets/number_buttons_grid.dart';
import 'package:chessudoku/ui/screens/game/widgets/sudoku_cell.dart';
import 'package:chessudoku/data/models/cell_content.dart';
import 'package:chessudoku/domain/enums/chess_piece.dart';

class InteractiveQueenRuleStep extends StatefulWidget {
  const InteractiveQueenRuleStep(
      {super.key, required this.translate, required this.onCompleted});

  final String Function(String, String) translate;
  final VoidCallback onCompleted;

  @override
  State<InteractiveQueenRuleStep> createState() =>
      _InteractiveQueenRuleStepState();
}

class _InteractiveQueenRuleStepState extends State<InteractiveQueenRuleStep> {
  final int qr = 4;
  final int qc = 4;
  bool _answered = false;
  bool _correct = false;

  bool _sameRow(int r) => r == qr;
  bool _sameCol(int c) => c == qc;
  bool _sameDiag(int r, int c) => (r - qr).abs() == (c - qc).abs();

  void _handleTap(int row, int col) {
    if (_answered) return;
    // 후보 A: (2,2) -> 같은 대각(제약), 후보 B: (2,3) -> 안전
    final isA = row == 2 && col == 2;
    final isB = row == 2 && col == 3;
    if (isB) {
      setState(() {
        _answered = true;
        _correct = true;
      });
      widget.onCompleted();
    } else if (isA) {
      setState(() {
        _answered = true;
        _correct = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translate;
    void showHint() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t('hint', '힌트')),
          content: Text(t('queen_hint', '퀸은 행/열/대각선 방향의 모든 칸을 제약합니다.')),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(t('ok', '확인'))),
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
          AspectRatio(
            aspectRatio: 1,
            child: Column(
              children: List.generate(9, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(9, (col) {
                      final isQueen = row == qr && col == qc;
                      final inCoverage =
                          _sameRow(row) || _sameCol(col) || _sameDiag(row, col);
                      final isCandidate =
                          (row == 2 && col == 2) || (row == 2 && col == 3);
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isQueen
                                ? Colors.amber.withValues(alpha: 0.6)
                                : isCandidate
                                    ? Colors.pinkAccent.withValues(alpha: 0.45)
                                    : inCoverage
                                        ? Colors.redAccent
                                            .withValues(alpha: 0.25)
                                        : null,
                          ),
                          child: SudokuCell(
                            row: row,
                            col: col,
                            cellContent: isQueen
                                ? const CellContent(
                                    chessPiece: ChessPiece.queen,
                                    isInitial: true)
                                : null,
                            isSelected: false,
                            isHighlighted: false,
                            hasError: false,
                            onTap: () => _handleTap(row, col),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t('queen_rule_prompt',
                        '퀸은 행/열/대각선 방향에 제약을 줍니다. 빨간 영역을 피해서 선택하세요.'),
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                ),
                TextButton(onPressed: showHint, child: const Text('Hint')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_answered)
            Text(
              _correct
                  ? t('correct_safe_cell', '정답! 안전한 칸이에요.')
                  : t('queen_wrong',
                      '퀸의 행/열/대각선 커버리지라 제약돼요. 힌트: 세 방향 모두 피하세요.'),
              style: TextStyle(
                  color:
                      _correct ? Colors.lightGreenAccent : Colors.amberAccent),
            ),
          const Spacer(),
          NumberButtonsGrid(
            selectedCellContent: null,
            onNumberTap: (_) {},
            onClearTap: () {},
            isNoteMode: false,
            isPaused: false,
          ),
        ],
      ),
    );
  }
}

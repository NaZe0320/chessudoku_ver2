import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/common/widgets/quick_play_button.dart';
import 'package:flutter/material.dart';

class QuickPlayGrid extends StatelessWidget {
  final Function(Difficulty) onQuickPlayTap;

  const QuickPlayGrid({
    super.key,
    required this.onQuickPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 태블릿/폴드 크기에서는 1x4 레이아웃, 그 외에는 2x2 레이아웃
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: QuickPlayButton(
                  difficulty: Difficulty.easy,
                  onTap: onQuickPlayTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickPlayButton(
                  difficulty: Difficulty.medium,
                  onTap: onQuickPlayTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickPlayButton(
                  difficulty: Difficulty.hard,
                  onTap: onQuickPlayTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickPlayButton(
                  difficulty: Difficulty.expert,
                  onTap: onQuickPlayTap,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: QuickPlayButton(
                      difficulty: Difficulty.easy,
                      onTap: onQuickPlayTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickPlayButton(
                      difficulty: Difficulty.medium,
                      onTap: onQuickPlayTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: QuickPlayButton(
                      difficulty: Difficulty.hard,
                      onTap: onQuickPlayTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickPlayButton(
                      difficulty: Difficulty.expert,
                      onTap: onQuickPlayTap,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

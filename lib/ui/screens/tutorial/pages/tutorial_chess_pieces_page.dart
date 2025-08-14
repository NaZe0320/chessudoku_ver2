import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class TutorialChessPiecesPage extends StatelessWidget {
  const TutorialChessPiecesPage({super.key, required this.translate});

  final String Function(String, String) translate;

  @override
  Widget build(BuildContext context) {
    final pieces = [
      _PieceRule(
        icon: Icons.looks_one,
        title: translate('king', '킹'),
        description: translate(
            'king_desc', '킹은 한 칸씩 모든 방향으로 이동할 수 있습니다. 체스룰에 따라 금지 영역을 표시합니다.'),
      ),
      _PieceRule(
        icon: Icons.looks_two,
        title: translate('queen', '퀸'),
        description:
            translate('queen_desc', '퀸은 가로, 세로, 대각선으로 여러 칸 이동할 수 있습니다.'),
      ),
      _PieceRule(
        icon: Icons.looks_3,
        title: translate('rook', '룩'),
        description: translate('rook_desc', '룩은 가로와 세로로 여러 칸 이동할 수 있습니다.'),
      ),
      _PieceRule(
        icon: Icons.looks_4,
        title: translate('bishop', '비숍'),
        description: translate('bishop_desc', '비숍은 대각선으로 여러 칸 이동할 수 있습니다.'),
      ),
      _PieceRule(
        icon: Icons.looks_5,
        title: translate('knight', '나이트'),
        description: translate('knight_desc', '나이트는 L자 형태(2칸+1칸)로 이동하며 점프합니다.'),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('chess_piece_rules', '체스 기물 사용법'),
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            translate(
                'chess_piece_rules_desc', '각 기물의 이동/제약 규칙에 따라 숫자 배치가 제한됩니다.'),
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: pieces.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PieceCard(rule: pieces[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceRule {
  _PieceRule(
      {required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

class _PieceCard extends StatelessWidget {
  const _PieceCard({required this.rule});
  final _PieceRule rule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(rule.icon, color: AppColors.textWhite),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rule.description,
                  style: TextStyle(
                    color: AppColors.textWhite.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chessudoku/presentation/theme/color_palette.dart';
import 'package:flutter/material.dart';

class TutorialSudokuRulesPage extends StatelessWidget {
  const TutorialSudokuRulesPage({super.key, required this.translate});

  final String Function(String, String) translate;

  @override
  Widget build(BuildContext context) {
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
            translate('sudoku_basics', '스도쿠 기본 규칙'),
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            translate('sudoku_rules_desc',
                '9x9 격자에서 가로, 세로, 3x3 박스에 1-9가 한 번씩만 들어가도록 채우세요.'),
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          _RuleItem(
            icon: Icons.grid_3x3,
            title: translate('rule_rows', '가로줄 규칙'),
            description:
                translate('rule_rows_desc', '각 가로줄에는 1-9가 중복 없이 한 번씩만 들어갑니다.'),
          ),
          _RuleItem(
            icon: Icons.view_week,
            title: translate('rule_cols', '세로줄 규칙'),
            description:
                translate('rule_cols_desc', '각 세로줄에는 1-9가 중복 없이 한 번씩만 들어갑니다.'),
          ),
          _RuleItem(
            icon: Icons.grid_view,
            title: translate('rule_boxes', '3x3 박스 규칙'),
            description: translate(
                'rule_boxes_desc', '각 3x3 박스에도 1-9가 중복 없이 한 번씩만 들어갑니다.'),
          ),
          const Spacer(),
          Center(
            child: Text(
              translate(
                  'hint_you_can_toggle_notes', '힌트: 메모 기능을 활용해 후보 숫자를 관리하세요.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem(
      {required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Icon(icon, color: AppColors.textWhite),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
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

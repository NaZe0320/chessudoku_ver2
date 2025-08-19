import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/presentation/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GameGuideScreen extends ConsumerWidget {
  const GameGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate('game_guide', '게임 가이드'),
          style: const TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GuideCard(
                title: translate('basic_controls', '기본 조작'),
                items: [
                  translate('select_cell', '셀 선택: 보드에서 칸을 탭해 선택하세요.'),
                  translate('enter_number', '숫자 입력: 하단 숫자 버튼을 눌러 입력하세요.'),
                  translate('notes_mode', '메모 모드: 후보 숫자를 기록할 수 있어요.'),
                ],
              ),
              _GuideCard(
                title: translate('chess_rules_affect', '체스 규칙 적용'),
                items: [
                  translate(
                      'chess_rules_desc', '선택한 기물의 이동/공격 범위에 따라 숫자 배치가 제한됩니다.'),
                  translate('king_rule', '예: 킹은 인접 칸에 같은 숫자가 올 수 없습니다.'),
                ],
              ),
              _GuideCard(
                title: translate('chess_pieces_rules', '체스 기물별 규칙'),
                items: [
                  translate('king_rule_desc', '♔ 킹: 인접 8칸에 같은 숫자를 둘 수 없습니다.'),
                  translate('queen_rule_desc',
                      '♕ 퀸: 같은 행/열/대각선 경로에 같은 숫자를 둘 수 없습니다.'),
                  translate(
                      'rook_rule_desc', '♖ 룩: 같은 행/열 경로에 같은 숫자를 둘 수 없습니다.'),
                  translate(
                      'bishop_rule_desc', '♗ 비숍: 대각선 경로에 같은 숫자를 둘 수 없습니다.'),
                  translate('knight_rule_desc',
                      '♘ 나이트: 나이트 이동(ㄴ자) 위치에 같은 숫자를 둘 수 없습니다.'),
                ],
              ),
              _GuideCard(
                title: translate('hints_and_helpers', '힌트 & 보조 기능'),
                items: [
                  translate('highlight_same_numbers', '같은 숫자 하이라이트'),
                  translate('scope_highlight', '선택 셀 행/열/박스 하이라이트'),
                  translate('auto_note_clear', '자동 메모 제거'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.title, required this.items});
  final String title;
  final List<String> items;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(color: AppColors.textWhite)),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

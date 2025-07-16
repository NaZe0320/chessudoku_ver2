import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/ui/common/widgets/continue_play_card.dart';
import 'package:chessudoku/ui/common/widgets/daily_challenge_card.dart';
import 'package:chessudoku/ui/common/widgets/stat_card.dart';
import 'package:chessudoku/ui/screens/profile/settings_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = ref.watch(translationProvider);

    return Scaffold(
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
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱 이름과 설정
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('app_name', 'ChesSudoku'),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: AppColors.textWhite,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 통계 카드들
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '47',
                        label: translate('completed_puzzles', '완료한 퍼즐'),
                        icon: Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '5일',
                        label: translate('current_streak', '연속 기록'),
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 이어서 플레이 카드
                ContinuePlayCard(
                  title: translate('continue_playing', '이어서 플레이'),
                  subtitle:
                      '${translate('normal_difficulty', '보통 난이도')} • ${translate('puzzle_8', '8번 정답')} • ${translate('progress_65', '65% 완료')}',
                  progressText: '',
                  progressValue: 0.65,
                  onTap: _onContinuePlayTap,
                ),
                const SizedBox(height: 16),

                // 일일 챌린지 카드
                DailyChallengeCard(
                  title: translate('daily_challenge', '일일 챌린지'),
                  streakText: translate('may_streak', '5월 연속'),
                  statusText: translate('challenge_status', '이번 주 진행 상황'),
                  messageText: translate(
                      'special_puzzle_message', '매일 특별한 퍼즐로 연속 기록을 쌓아보세요!'),
                  onDayTap: _onDayProgressTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDayProgressTap(String day) {
    // TODO: 일일 챌린지 퍼즐 화면으로 이동
    print('$day 일일 챌린지 퍼즐 진입');
  }

  void _onContinuePlayTap() {
    // TODO: 이어서 플레이 게임 화면으로 이동
    print('이어서 플레이 게임 진입');
  }
}

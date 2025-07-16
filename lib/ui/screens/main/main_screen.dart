import 'package:chessudoku/core/di/language_pack_provider.dart';
import 'package:chessudoku/data/models/day_progress.dart';
import 'package:chessudoku/domain/enums/day_status.dart';
import 'package:chessudoku/ui/common/widgets/continue_game_button.dart';
import 'package:chessudoku/ui/common/widgets/stat_card.dart';
import 'package:chessudoku/ui/common/widgets/daily_challenge_card.dart';
import 'package:chessudoku/ui/common/widgets/difficulty_buttons_widget.dart';
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
            padding: const EdgeInsets.all(16.0),
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

                const SizedBox(height: 32),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Row(
                    children: [
                      StatCard(
                        emoji: '✓',
                        number: '12',
                        label: '완료',
                      ),
                      SizedBox(width: 12),
                      StatCard(
                        emoji: '🔥',
                        number: '5',
                        label: '연속',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 이어하기 카드
                const ContinueGameButton(),

                const SizedBox(height: 24),

                // 일일 챌린지 카드
                const DailyChallengeCard(
                  streakDays: 5, // 예시로 5일 연속 
                  weekProgress: [
                    DayProgress(label: '월', status: DayStatus.completed),
                    DayProgress(label: '화', status: DayStatus.completed),
                    DayProgress(label: '수', status: DayStatus.completed),
                    DayProgress(label: '목', status: DayStatus.completed),
                    DayProgress(label: '금', status: DayStatus.completed),
                  ],
                ),

                const SizedBox(height: 32),

                // 하단 메시지
                Center(
                  child: Text(
                    translate('daily_new_puzzle_message',
                        '매일 새로운 퍼즐로 업그를 수 있는 기회를 놓아보세요!'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 퍼즐 플레이 섹션
                const DifficultyButtonsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

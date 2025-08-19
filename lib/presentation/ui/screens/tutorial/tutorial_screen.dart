import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/di/language_pack_provider.dart';

import 'package:chessudoku/presentation/ui/screens/main/main_screen.dart';
import 'package:chessudoku/presentation/ui/screens/tutorial/pages/tutorial_sudoku_rules_page.dart';
import 'package:chessudoku/presentation/ui/screens/tutorial/pages/tutorial_chess_pieces_page.dart';
import 'package:chessudoku/presentation/ui/theme/color_palette.dart';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TutorialScreen extends HookConsumerWidget {
  const TutorialScreen({super.key, this.launchedFromSettings = false});

  final bool launchedFromSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController();
    final currentPage = useState<int>(0);
    final translate = ref.watch(translationProvider);

    final completedSteps = useState<Set<int>>({});

    final pages = [
      TutorialSudokuRulesPage(translate: translate),
      TutorialChessPiecesPage(translate: translate),
      _TutorialFinalPage(translate: translate),
    ];

    Future<void> completeTutorial() async {
      final cache = ref.read(cacheServiceProvider);
      await cache.setBool('tutorial_completed', true);
      if (launchedFromSettings) {
        if (context.mounted) Navigator.of(context).pop();
      } else {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (currentPage.value < pages.length - 1)
            TextButton(
              onPressed: completeTutorial,
              child: Text(
                translate('skip', '건너뛰기'),
                style: const TextStyle(color: AppColors.textWhite),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스와이프는 막되, 내부 위젯 터치는 가능하도록 설정
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (i) => currentPage.value = i,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages.length,
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final isActive = i == currentPage.value;
                final isCompleted = completedSteps.value.contains(i);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.accent
                        : (isActive
                            ? AppColors.textWhite
                            : AppColors.textWhite.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (currentPage.value > 0) {
                          controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        translate('previous', '이전'),
                        style: const TextStyle(color: AppColors.textWhite),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(builder: (context) {
                      final isLast = currentPage.value == pages.length - 1;
                      final requiresCompletion = <int>{};
                      final mustComplete =
                          requiresCompletion.contains(currentPage.value);
                      final isStepCompleted =
                          completedSteps.value.contains(currentPage.value);
                      final isDisabled =
                          mustComplete && !isStepCompleted && !isLast;

                      return ElevatedButton(
                        onPressed: isDisabled
                            ? null
                            : () async {
                                if (isLast) {
                                  await completeTutorial();
                                } else {
                                  controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor:
                              AppColors.textWhite.withValues(alpha: 0.25),
                          disabledForegroundColor:
                              AppColors.textWhite.withValues(alpha: 0.6),
                        ),
                        child: Text(
                          isLast
                              ? translate('start_playing', '시작하기')
                              : (isDisabled
                                  ? translate('complete_step_to_continue',
                                      '이 단계를 완료하면 계속할 수 있어요')
                                  : translate('next', '다음')),
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialFinalPage extends StatelessWidget {
  const _TutorialFinalPage({required this.translate});

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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 72, color: AppColors.textWhite),
          const SizedBox(height: 16),
          Text(
            translate('you_are_ready', '이제 준비되었어요!'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate('tutorial_final_desc', '지금 바로 ChesSudoku를 즐겨보세요.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textWhite.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

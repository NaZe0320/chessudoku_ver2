import 'package:chessudoku/core/di/tab_provider.dart';
import 'package:chessudoku/core/di/puzzle_pack_provider.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/app_bar_icon_button.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/chess_pattern.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/stat_card.dart';
// import 'package:chessudoku/ui/common/widgets/tab_bar/floating_tab_bar.dart';
// import 'package:chessudoku/ui/common/widgets/tab_bar/sliver_tab_bar_delegate.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/tab_content.dart';
// import 'package:chessudoku/ui/screens/pack/tab/difficulty_tab_content.dart';
// import 'package:chessudoku/ui/screens/pack/tab/progress_tab_content.dart';
import 'package:chessudoku/ui/screens/pack/tab/recommend_pack_tab_content.dart';
// import 'package:chessudoku/ui/screens/pack/tab/theme_tab_content.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PackScreen extends HookConsumerWidget {
  const PackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final isScrolled = useState(false);

    // 퍼즐 팩 상태 관리
    final puzzlePackState = ref.watch(puzzlePackNotifierProvider);
    final puzzlePackNotifier = ref.read(puzzlePackNotifierProvider.notifier);

    // final List<String> tabs = ['추천', '난이도별', '테마별', '진행 중'];
    final List<Widget> tabViews = [
      const RecommendPackTabContent(),
      // const DifficultyPackTabContent(),
      // const ThemePackTabContent(),
      // const ProgressPackTabContent(),
    ];

    // 컴포넌트 마운트 시 퍼즐 팩 데이터 로드
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        puzzlePackNotifier.loadPuzzlePacks();
      });
      return null;
    }, []);

    void listenToScrollChange() {
      if (scrollController.offset >= 50) {
        isScrolled.value = true;
      } else {
        isScrolled.value = false;
      }
    }

    useEffect(() {
      scrollController.addListener(listenToScrollChange);
      return () => scrollController.removeListener(listenToScrollChange);
    }, [scrollController]);

    // 통계 계산
    final totalPacks = puzzlePackState.puzzlePacks.length;
    final completedPacks =
        puzzlePackState.puzzlePacks.where((pack) => pack.isCompleted).length;
    final completedPuzzles = puzzlePackState.puzzlePacks
        .fold<int>(0, (sum, pack) => sum + pack.completedPuzzles);
    final progressRate =
        totalPacks > 0 ? (completedPacks / totalPacks * 100).round() : 0;

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              title: AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isScrolled.value ? 20.0 : 24.0,
                  fontWeight:
                      isScrolled.value ? FontWeight.w500 : FontWeight.bold,
                ),
                duration: const Duration(milliseconds: 200),
                child: const Text("퍼즐팩"),
              ),
              actions: [
                AppBarIconButton(
                  icon: Icons.search_outlined,
                  isScrolled: isScrolled.value,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  onPressed: () {},
                ),
                AppBarIconButton(
                  icon: Icons.filter_list_outlined,
                  isScrolled: isScrolled.value,
                  margin: const EdgeInsets.only(
                      right: 8.0, left: 4.0, top: 8.0, bottom: 8.0),
                  onPressed: () {},
                ),
              ],
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    Opacity(
                      opacity: 0.25,
                      child: CustomPaint(
                        painter: ChessPatternPainter(),
                        size: const Size(double.infinity, double.infinity),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AnimatedOpacity(
                          opacity: isScrolled.value ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "닉네임",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              puzzlePackState.isLoading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "통계 로딩 중...",
                                          style:
                                              TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    )
                                  : puzzlePackState.errorMessage != null
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.white70,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              "통계 로딩 실패",
                                              style: TextStyle(
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            StatCard(
                                              title: "완료한 팩",
                                              value:
                                                  "$completedPacks/$totalPacks",
                                              icon: Icons.today_outlined,
                                            ),
                                            StatCard(
                                              title: "팩 진행률",
                                              value: "$progressRate%",
                                              icon: Icons.bar_chart_outlined,
                                            ),
                                            StatCard(
                                              title: "해결한 퍼즐",
                                              value: "$completedPuzzles",
                                              icon: Icons.star_outline,
                                            ),
                                          ],
                                        ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SliverPersistentHeader(
            //   pinned: true,
            //   delegate: SliverTabBarDelegate(
            //     FloatingTabBar(
            //       tabs: _tabs,
            //       provider: packTabProvider,
            //     ),
            //   ),
            // ),
            SliverToBoxAdapter(
              child: TabContent(
                tabViews: tabViews,
                provider: packTabProvider,
              ),
            ),
          ],
        )
      ],
    );
  }
}

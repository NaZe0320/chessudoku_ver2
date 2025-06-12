import 'package:chessudoku/core/di/tab_provider.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/app_bar_icon_button.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/chess_pattern.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/stat_card.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/floating_tab_bar.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/sliver_tab_bar_delegate.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/tab_content.dart';
import 'package:chessudoku/ui/screens/home/tab/challenge_tab_content.dart';
import 'package:chessudoku/ui/screens/home/tab/history_tab_content.dart';
import 'package:chessudoku/ui/screens/home/tab/home_tab_content.dart';
import 'package:chessudoku/ui/screens/home/tab/recommend_tab_content.dart';
import 'package:chessudoku/ui/screens/notice/notice_screen.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final isScrolled = useState(false);

    final List<String> tabs = ['홈', '도전', '기록', '추천'];
    final List<Widget> tabViews = [
      const HomeTabContent(),
      const ChallengeTabContent(),
      const HistoryTabContent(),
      const RecommendTabContent(),
    ];

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
                child: const Text("체스도쿠"),
              ),
              actions: [
                AppBarIconButton(
                  icon: Icons.notifications_outlined,
                  isScrolled: isScrolled.value,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoticeScreen(),
                      ),
                    );
                  },
                ),
                AppBarIconButton(
                  icon: Icons.settings_outlined,
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
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "닉네임",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  StatCard(
                                      title: "오늘",
                                      value: "32",
                                      icon: Icons.today_outlined),
                                  StatCard(
                                      title: "승률",
                                      value: "75%",
                                      icon: Icons.bar_chart_outlined),
                                  StatCard(
                                      title: "포인트",
                                      value: "1,250",
                                      icon: Icons.star_outline),
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
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegate(
                FloatingTabBar(
                  tabs: tabs,
                  provider: homeTabProvider,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 180,
                ),
                child: TabContent(
                  tabViews: tabViews,
                  provider: homeTabProvider,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

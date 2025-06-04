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
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  final List<String> _tabs = ['홈', '도전', '기록', '추천'];
  late final List<Widget> _tabViews;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _tabViews = [
      const HomeTabContent(),
      const ChallengeTabContent(),
      const HistoryTabContent(),
      const RecommendTabContent(),
    ];

    _scrollController.addListener(_listenToScrollChange);
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 50) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              title: AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _isScrolled ? 20.0 : 24.0,
                  fontWeight: _isScrolled ? FontWeight.w500 : FontWeight.bold,
                ),
                duration: const Duration(milliseconds: 200),
                child: const Text("체스도쿠"),
              ),
              actions: [
                AppBarIconButton(
                  icon: Icons.notifications_outlined,
                  isScrolled: _isScrolled,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  onPressed: () {},
                ),
                AppBarIconButton(
                  icon: Icons.settings_outlined,
                  isScrolled: _isScrolled,
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
                          opacity: _isScrolled ? 0.0 : 1.0,
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
                  tabs: _tabs,
                  provider: homeTabProvider,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TabContent(
                tabViews: _tabViews,
                provider: homeTabProvider,
              ),
            ),
          ],
        )
      ],
    );
  }
}

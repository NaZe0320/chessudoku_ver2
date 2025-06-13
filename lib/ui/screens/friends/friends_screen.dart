import 'package:chessudoku/core/di/tab_provider.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/app_bar_icon_button.dart';
import 'package:chessudoku/ui/common/widgets/app_bar/chess_pattern.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/floating_tab_bar.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/sliver_tab_bar_delegate.dart';
import 'package:chessudoku/ui/common/widgets/tab_bar/tab_content.dart';
import 'package:chessudoku/ui/screens/friends/tab/friends_list_tab_content.dart';
import 'package:chessudoku/ui/screens/friends/tab/battle_history_tab_content.dart';
import 'package:chessudoku/ui/screens/friends/tab/ranking_tab_content.dart';
import 'package:chessudoku/ui/screens/friends/tab/requests_tab_content.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FriendsScreen extends HookConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final isScrolled = useState(false);

    final List<String> tabs = ['친구 목록', '대결 기록', '랭킹', '신청'];
    final List<Widget> tabViews = [
      const FriendsListTabContent(),
      const BattleHistoryTabContent(),
      const RankingTabContent(),
      const RequestsTabContent(),
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
                child: const Text("친구"),
              ),
              actions: [
                AppBarIconButton(
                  icon: Icons.person_add_outlined,
                  isScrolled: isScrolled.value,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  onPressed: () {
                    // 친구 추가 기능
                  },
                ),
                AppBarIconButton(
                  icon: Icons.search_outlined,
                  isScrolled: isScrolled.value,
                  margin: const EdgeInsets.only(
                      right: 8.0, left: 4.0, top: 8.0, bottom: 8.0),
                  onPressed: () {
                    // 친구 검색 기능
                  },
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
                                "소셜 게임 즐기기",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _StatCard(
                                      title: "친구",
                                      value: "15",
                                      icon: Icons.people_outline),
                                  _StatCard(
                                      title: "승률",
                                      value: "68%",
                                      icon: Icons.trending_up_outlined),
                                  _StatCard(
                                      title: "랭킹",
                                      value: "#42",
                                      icon: Icons.emoji_events_outlined),
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
                  provider: friendsTabProvider,
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
                  provider: friendsTabProvider,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

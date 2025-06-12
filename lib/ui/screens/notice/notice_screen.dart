import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../common/widgets/app_bar/chess_pattern.dart';
import '../../common/widgets/app_bar/app_bar_icon_button.dart';

class NoticeScreen extends HookConsumerWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 4);

    Widget buildTab(String title, String count, int index) {
      return AnimatedBuilder(
        animation: tabController,
        builder: (context, child) {
          final isCurrentSelected = tabController.index == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentSelected
                  ? const Color(0xFF1E40AF)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCurrentSelected ? Colors.white : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // 커스텀 앱바
          Container(
            color: AppColors.primary,
            child: Stack(
              children: [
                // 체스 패턴 배경
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.25,
                    child: CustomPaint(
                      painter: ChessPatternPainter(),
                      size: const Size(double.infinity, double.infinity),
                    ),
                  ),
                ),
                // 앱바 내용
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단 헤더 (뒤로가기 버튼, 체크마크, 설정)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppBarIconButton(
                              icon: Icons.arrow_back,
                              isScrolled: false,
                              margin: const EdgeInsets.all(0),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Row(
                              children: [
                                AppBarIconButton(
                                  icon: Icons.check,
                                  isScrolled: false,
                                  margin: const EdgeInsets.only(
                                      right: 8.0,
                                      left: 4.0,
                                      top: 8.0,
                                      bottom: 8.0),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 8),
                                AppBarIconButton(
                                  icon: Icons.settings,
                                  isScrolled: false,
                                  margin: const EdgeInsets.only(
                                      right: 8.0,
                                      left: 4.0,
                                      top: 8.0,
                                      bottom: 8.0),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 제목과 설명
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '알림',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '총 12개의 알림',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(208),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            // 읽지 않음 버튼
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(52),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '0개 읽지 않음',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(208),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 탭바
          Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.transparent,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: [
                Tab(child: buildTab('전체', '13', 0)),
                Tab(child: buildTab('친구', '3', 1)),
                Tab(child: buildTab('게임', '4', 2)),
                Tab(child: buildTab('시스템', '5', 3)),
              ],
            ),
          ),

          // 탭뷰 내용
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                Center(child: Text('전체 알림')),
                Center(child: Text('친구 알림')),
                Center(child: Text('게임 알림')),
                Center(child: Text('시스템 알림')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

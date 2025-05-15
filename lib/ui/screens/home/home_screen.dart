import 'package:chessudoku/ui/common/widgets/app_bar/chess_pattern.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/dimensions.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

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
        CustomScrollView(controller: _scrollController, slivers: [
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
                margin:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                    "오늘", "32", Icons.today_outlined),
                                _buildStatCard(
                                    "승률", "75%", Icons.bar_chart_outlined),
                                _buildStatCard(
                                    "포인트", "1,250", Icons.star_outline),
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Spacing.space4),
              child: Column(
                children: [
                  // 컨텐츠 삽입입
                  Text('오늘의 목표'),
                  SizedBox(height: 160),
                  Text('오늘의 목표1'),
                  SizedBox(height: 160),
                  Text('오늘의 목표2'),
                  SizedBox(height: 160),
                  Text('오늘의 목표3'),
                  SizedBox(height: 160),
                  Text('오늘의 목표4'),
                ],
              ),
            ),
          ),
        ])
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(52),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          Text(title,
              style: TextStyle(
                color: Colors.white.withAlpha(208),
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isScrolled;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.isScrolled,
    required this.onPressed,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      decoration: BoxDecoration(
        color: isScrolled ? Colors.transparent : Colors.white.withAlpha(52),
        borderRadius: BorderRadius.circular(24),
        shape: BoxShape.rectangle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8.0),
        iconSize: 24.0,
      ),
    );
  }
}

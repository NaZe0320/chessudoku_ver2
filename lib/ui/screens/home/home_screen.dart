import 'package:chessudoku/ui/common/widgets/app_bar/collapsing_app_bar.dart';

import 'package:chessudoku/ui/theme/dimensions.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHeaderCollapsed = false;
  final _scrollController = ScrollController();
  final int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = true;
      });
    } else if (_scrollController.offset <= 50 && _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(controller: _scrollController, slivers: [
          SliverToBoxAdapter(
            child: CollapsingAppBar(
              isCollapsed: _isHeaderCollapsed,
              title: '체스도쿠',
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              stats: const [
                Text('100'),
                Text('100'),
              ],
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
}
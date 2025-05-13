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
            title: const Text("체스도쿠", style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Opacity(
                opacity: 0.25,
                child: CustomPaint(
                  painter: ChessPatternPainter(),
                  size: const Size(double.infinity, double.infinity),
                ),
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
}

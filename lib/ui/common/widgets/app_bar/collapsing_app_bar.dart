import 'package:chessudoku/ui/common/widgets/app_bar/chess_pattern.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:chessudoku/ui/theme/dimensions.dart';
import 'package:chessudoku/ui/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CollapsingAppBar extends StatelessWidget {
  final bool isCollapsed;
  final String title;
  final List<Widget> actions;
  final List<Widget> stats;

  const CollapsingAppBar({
    super.key,
    required this.isCollapsed,
    required this.title,
    this.actions = const [],
    this.stats = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 200),
      height: isCollapsed ? Spacing.collapsedHeaderHeight : Spacing.expandedHeaderHeight,
      child: Stack(
        children: [
          // 배경 그라데이션
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 체스 패턴
          Opacity(
            opacity: 0.25,
            child: CustomPaint(
              painter: ChessPatternPainter(),
              size: Size.infinite,
            ),
          ),

          // 앱바 내용
          Padding(
            padding: EdgeInsets.only(
              left: Spacing.space4,
              right: Spacing.space4,
              top: MediaQuery.of(context).padding.top + Spacing.space2,
              bottom: Spacing.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isCollapsed ? 32 : 40,
                          height: isCollapsed ? 32 : 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(Spacing.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(child: Text('로고') //AppLogo(size: isCollapsed ? 20 : 24),
                              ),
                        ),
                        const SizedBox(width: Spacing.space2),
                        Text(
                          title,
                          style: AppTypography.heading1.copyWith(
                            color: Colors.white,
                            fontSize: isCollapsed ? 18 : 22,
                          ),
                        ),
                      ],
                    ),
                    // 액션 버튼들
                    Row(children: actions),
                  ],
                ),
                // 통계 영역 (축소 시 숨김)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: isCollapsed ? 0 : 80,
                    margin: EdgeInsets.only(top: isCollapsed ? 0 : Spacing.space5),
                    child: isCollapsed ? const SizedBox() : Row(children: stats),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

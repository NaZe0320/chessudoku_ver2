import 'dart:ui';

import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class ContinueGameButton extends StatefulWidget {
  final String title;
  final String difficulty;
  final String timeElapsed;
  final double progress; // 0.0 to 1.0
  final String icon;
  final VoidCallback? onTap;

  const ContinueGameButton({
    Key? key,
    this.title = '이어하기',
    this.difficulty = '보통 난이도',
    this.timeElapsed = '12분 경과',
    this.progress = 0.65,
    this.icon = '♞',
    this.onTap,
  }) : super(key: key);

  @override
  State<ContinueGameButton> createState() => _ContinueGameButtonState();
}

class _ContinueGameButtonState extends State<ContinueGameButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isPressed
                        ? [
                            AppColors.accent.withValues(alpha: 0.3),
                            AppColors.accentLight.withValues(alpha: 0.3),
                          ]
                        : [
                            AppColors.accent.withValues(alpha: 0.2),
                            AppColors.accentLight.withValues(alpha: 0.2),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPressed
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : AppColors.accent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // 아이콘
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                widget.icon,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 게임 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 제목
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // 세부 정보
                                Row(
                                  children: [
                                    Text(
                                      widget.difficulty,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textWhite
                                            .withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: 2,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppColors.textWhite
                                            .withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    Text(
                                      widget.timeElapsed,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textWhite
                                            .withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      width: 2,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: AppColors.textWhite
                                            .withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    Text(
                                      '${(widget.progress * 100).round()}% 완료',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textWhite
                                            .withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // 진행률 바
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: widget.progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surface
                                            .withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 화살표 아이콘
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textWhite.withValues(alpha: 0.6),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:ui';
import 'package:chessudoku/data/models/day_progress.dart';
import 'package:chessudoku/domain/enums/day_status.dart';
import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class DailyChallengeCard extends StatefulWidget {
  final int streakDays;
  final List<DayProgress> weekProgress;
  final VoidCallback? onTap;

  const DailyChallengeCard({
    Key? key,
    required this.streakDays,
    required this.weekProgress,
    this.onTap,
  }) : super(key: key);

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();

    // 펄스 애니메이션 (오늘 날짜용)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 호버 애니메이션
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -2 * _hoverAnimation.value),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 320,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent
                          .withValues(alpha: 0.2 + 0.1 * _hoverAnimation.value),
                      AppColors.accentLight
                          .withValues(alpha: 0.2 + 0.1 * _hoverAnimation.value),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.accent
                        .withValues(alpha: 0.3 + 0.2 * _hoverAnimation.value),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent
                          .withValues(alpha: 0.2 * _hoverAnimation.value),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildWeekProgress(),
                          const SizedBox(height: 20),
                          _buildDescription(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Text(
              '🗓️',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(width: 8),
            Text(
              '일일 챌린지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.streakDays}일 연속',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekProgress() {
    return Column(
      children: [
        const Text(
          '이번 주 진행 상황',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              widget.weekProgress.map((day) => _buildDayItem(day)).toList(),
        ),
      ],
    );
  }

  Widget _buildDayItem(DayProgress day) {
    return Column(
      children: [
        Text(
          day.label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        _buildDayCircle(day.status),
      ],
    );
  }

  Widget _buildDayCircle(DayStatus status) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    String icon;
    Widget? child;

    switch (status) {
      case DayStatus.completed:
        backgroundColor = AppColors.success.withValues(alpha: 0.3);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = '✓';
        break;
      case DayStatus.missed:
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        borderColor = Colors.red;
        textColor = Colors.red;
        icon = '✗';
        break;
      case DayStatus.today:
        backgroundColor = AppColors.accent.withValues(alpha: 0.3);
        borderColor = AppColors.accent;
        textColor = AppColors.accent;
        icon = '';
        child = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case DayStatus.upcoming:
        backgroundColor = Colors.white.withValues(alpha: 0.1);
        borderColor = Colors.white.withValues(alpha: 0.2);
        textColor = Colors.white.withValues(alpha: 0.5);
        icon = '○';
        break;
    }

    if (child != null) {
      return child;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      '매일 특별한 퍼즐로 도전하세요!',
      style: TextStyle(
        fontSize: 13,
        color: Colors.white.withValues(alpha: 0.8),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}

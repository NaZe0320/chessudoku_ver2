import 'dart:ui';

import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  final String? emoji;
  final Color? numberColor;

  const StatCard({
    Key? key,
    required this.number,
    required this.label,
    this.emoji,
    this.numberColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji != null ? '$emoji $number' : number,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: numberColor ?? AppColors.textWhite,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';

class AppTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    color: AppColors.textTertiary,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
  );
  
  static const TextStyle tabLabel = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle navLabel = TextStyle(
    fontSize: 11.0,
  );
  
  static const TextStyle statValue = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle statTitle = TextStyle(
    fontSize: 10.0,
    color: Colors.white70,
  );
}
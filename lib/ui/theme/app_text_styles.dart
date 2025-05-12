import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // 기본 폰트 패밀리
  static const String _fontFamily = 'Pretendard'; // 또는 'NotoSansKR'로 변경 가능

  // 헤드라인 스타일
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors2.neutral900,
    letterSpacing: -0.5,
    height: 1.2,
    fontFamily: _fontFamily,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors2.neutral900,
    letterSpacing: -0.25,
    height: 1.3,
    fontFamily: _fontFamily,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors2.neutral900,
    letterSpacing: 0,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // 부제목 스타일
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors2.neutral800,
    letterSpacing: 0.15,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors2.neutral800,
    letterSpacing: 0.1,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  // 본문 스타일
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors2.neutral800,
    letterSpacing: 0.15,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors2.neutral700,
    letterSpacing: 0.25,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors2.neutral700,
    letterSpacing: 0.4,
    height: 1.5,
    fontFamily: _fontFamily,
  );

  // 캡션 스타일
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors2.neutral600,
    letterSpacing: 0.4,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // 버튼 스타일
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors2.neutral100,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors2.neutral100,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors2.neutral100,
    letterSpacing: 0.5,
    height: 1.4,
    fontFamily: _fontFamily,
  );

  // 셀 스타일 (추가)
  static TextStyle cellNumber({bool isInitial = false}) => TextStyle(
        fontSize: 20,
        fontWeight: isInitial ? FontWeight.bold : FontWeight.w500,
        color: isInitial ? AppColors2.neutral900 : AppColors2.primary,
        letterSpacing: 0,
        fontFamily: _fontFamily,
      );

  static const TextStyle cellNote = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.normal,
    color: AppColors2.neutral600,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );
}

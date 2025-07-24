import 'package:flutter/material.dart';

class AppColors {
  // 브랜드 컬러 (CSS 그라데이션 기반)
  static const primary = Color(0xFF1E40AF); // Blue-700 (그라데이션 중앙)
  static const primaryLight = Color(0xFF2563EB); // Blue-600 (그라데이션 끝)
  static const primaryDark = Color(0xFF1E3A8A); // Blue-800 (그라데이션 시작)
  static const secondary = Color(0xFF818CF8); // Indigo-400
  static const accent = Color(0xFF10B981); // Emerald-500
  static const accentLight = Color(0xFF34D399); // Emerald-400

  // 그라데이션 컬러들
  static const gradientStart = Color(0xFF1E3A8A); // Blue-800
  static const gradientMiddle = Color(0xFF1E40AF); // Blue-700
  static const gradientEnd = Color(0xFF2563EB); // Blue-600

  // 기능적 컬러 (Tailwind 기반)
  static const info = Color(0xFF06B6D4); // Cyan-500
  static const infoLight = Color(0xFFE0F7FA); // Cyan-50
  static const success = Color(0xFF059669); // Emerald-600
  static const successLight = Color(0xFFD1FAE5); // Emerald-100
  static const warning = Color(0xFFF59E0B); // Amber-500
  static const warningLight = Color(0xFFFEF3C7); // Amber-100
  static const error = Color(0xFFEF4444); // Red-500
  static const errorLight = Color(0xFFFEE2E2); // Red-100

  // 중립 컬러 (더 밝고 깔끔한 톤)
  static const background = Color(0xFFFAFAFA); // Gray-50
  static const surface = Color(0xFFFFFFFF); // White
  static const surfaceSecondary = Color(0xFFF9FAFB); // Gray-50
  static const onSurface = Color(0xFF111827); // Gray-900
  static const textPrimary = Color(0xFF111827); // Gray-900
  static const textSecondary = Color(0xFF374151); // Gray-700
  static const textTertiary = Color(0xFF6B7280); // Gray-500
  static const textWhite = Color(0xFFFFFFFF); // White

  static const divider = Color(0xFFE5E7EB); // Gray-200

  // 뉴트럴 컬러 스케일 (Tailwind Gray)
  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral700 = Color(0xFF374151);
  static const neutral800 = Color(0xFF1F2937);
  static const neutral900 = Color(0xFF111827);

  // 추가 액센트 컬러
  static const purple = Color(0xFF8B5CF6); // Violet-500
  static const pink = Color(0xFFEC4899); // Pink-500
  static const orange = Color(0xFFF97316); // Orange-500
  static const teal = Color(0xFF14B8A6); // Teal-500

  // 그라데이션 정의
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gradientStart, // #1e3a8a
      gradientMiddle, // #1e40af
      gradientEnd, // #2563eb
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

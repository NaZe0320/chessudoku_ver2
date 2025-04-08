import 'package:flutter/material.dart';

class AppColors {
  // 기본 색상 (벚꽃 계열로 변경)
  static const Color primary = Color(0xFFFF8DC7); // 연한 벚꽃 핑크
  static const Color primaryLight = Color(0xFFFFB5D8); // 더 연한 핑크
  static const Color primaryDark = Color(0xFFE56B9F); // 진한 핑크

  // 보조 색상 (벚꽃 테마와 어울리는 색상으로 업데이트)
  static const Color secondary = Color(0xFF82C4C3); // 민트 그린
  static const Color secondaryLight = Color(0xFFA1D7D6); // 연한 민트
  static const Color secondaryDark = Color(0xFF5BA3A1); // 진한 민트

  // Semantic 색상 (벚꽃 테마와 어울리도록 약간 조정)
  static const Color success = Color(0xFF5CB176); // 연두색
  static const Color warning = Color(0xFFFFB547); // 주황색
  static const Color error = Color(0xFFE53935); // 연한 빨강
  static const Color info = Color(0xFF57BED0); // 하늘색

  // 중립 색상 (따뜻한 뉘앙스로 업데이트)
  static const Color neutral100 = Color(0xFFFFFBFB); // 매우 연한 핑크 톤의 흰색
  static const Color neutral200 = Color(0xFFF8F0F3); // 연한 핑크 톤
  static const Color neutral300 = Color(0xFFEDE2E5); // 연한 핑크 그레이
  static const Color neutral400 = Color(0xFFD0C5C9); // 중간 핑크 그레이
  static const Color neutral500 = Color(0xFFADA0A5); // 중간 그레이
  static const Color neutral600 = Color(0xFF8D8187); // 진한 핑크 그레이
  static const Color neutral700 = Color(0xFF6D6267); // 매우 진한 핑크 그레이
  static const Color neutral800 = Color(0xFF4A4145); // 다크 그레이
  static const Color neutral900 = Color(0xFF332F31); // 거의 검정

  // 새로운 강조 색상 (벚꽃 테마에 어울리는 색상들)
  static const Color accent1 = Color(0xFF9F91CC); // 라벤더
  static const Color accent2 = Color(0xFFF0A5B3); // 코랄 핑크
  static const Color accent3 = Color(0xFFFDE2C8); // 살구색

  // 그라데이션 색상
  static const List<Color> pinkGradient = [
    Color(0xFFFF8DC7),
    Color(0xFFFFB5D8),
  ];

  static const List<Color> mintGradient = [
    Color(0xFF82C4C3),
    Color(0xFFA1D7D6),
  ];
}

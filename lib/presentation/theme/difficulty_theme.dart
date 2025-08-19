import 'package:flutter/material.dart';
import 'package:chessudoku/core/enums/difficulty.dart';

/// 난이도별 UI 테마 확장
extension DifficultyTheme on Difficulty {
  /// 난이도별 색상
  Color get color {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50); // 초록색
      case Difficulty.medium:
        return const Color(0xFFFF9800); // 주황색
      case Difficulty.hard:
        return const Color(0xFFF44336); // 빨간색
      case Difficulty.expert:
        return const Color(0xFF9C27B0); // 보라색
    }
  }

  /// 난이도별 설명
  String get description {
    switch (this) {
      case Difficulty.easy:
        return '폰 · 입문자용';
      case Difficulty.medium:
        return '나이트 · 적당한 도전';
      case Difficulty.hard:
        return '비숍 · 도전적인';
      case Difficulty.expert:
        return '퀸 · 최고 난이도';
    }
  }
}

import 'package:chessudoku/domain/enums/difficulty.dart';
import 'package:chessudoku/ui/common/widgets/button_example.dart';
import 'package:chessudoku/ui/screens/home/home_page.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';
import 'package:chessudoku/ui/screens/puzzle/puzzle_page.dart';
import 'package:chessudoku/ui/screens/puzzle/puzzle_screen.dart';
import 'package:chessudoku/ui/screens/records/records_page.dart';
import 'package:chessudoku/ui/screens/test/test_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String puzzle = '/puzzle';
  static const String puzzleGame = '/puzzle/game';
  static const String records = '/records';
  static const String social = '/social';
  static const String profile = '/profile';
  static const String store = '/store';

  // 바텀 네비게이션 인덱스와 라우트 매핑
  static const Map<int, String> indexToRoute = {
    0: home,
    1: puzzle,
    2: social,
    3: profile,
    4: store,
  };

  // 라우트에서 인덱스로 변환
  static int getIndexFromRoute(String route) {
    return indexToRoute.entries
        .firstWhere((entry) => entry.value == route,
            orElse: () => const MapEntry(0, ''))
        .key;
  }

  // 바텀 네비게이션에 사용할 페이지 리스트
  static final List<Widget> navigationPages = [
    const HomePage(),
    const PuzzlePage(),
    const ButtonExample(),
    const TestPage(),
    const TestPage(),
  ];

  // 퍼즐 화면으로 이동
  static void navigateToPuzzleScreen(
      BuildContext context, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PuzzleScreen()),
    );
  }

  // 기록실 화면으로 이동
  static void navigateToRecordsPage(BuildContext context) {
    Navigator.pushNamed(context, records);
  }

  static Map<String, WidgetBuilder> get routes => {
        main: (context) => const MainScreen(),
        home: (context) => const HomePage(),
        puzzle: (context) => const PuzzlePage(),
        puzzleGame: (context) => const PuzzleScreen(),
        records: (context) => const RecordsPage(),
        social: (context) => const ButtonExample(),
        profile: (context) => const TestPage(),
        store: (context) => const TestPage(),
      };
}

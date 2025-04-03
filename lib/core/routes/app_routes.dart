import 'package:chessudoku/ui/screens/home/home_page.dart';
import 'package:chessudoku/ui/screens/main/main_screen.dart';
import 'package:chessudoku/ui/screens/puzzle/puzzle_page.dart';
import 'package:chessudoku/ui/screens/test/test_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String puzzle = 'puzzle';
  static const String social = '/social';
  static const String profile = '/profile';
  static const String store = '/store';

  static Map<String, WidgetBuilder> get routes => {
        main: (context) => MainScreen(),
        home: (context) => const HomePage(),
        puzzle: (context) => const PuzzlePage(),
        social: (context) => const TestPage(),
        profile: (context) => const TestPage(),
        store: (context) => const TestPage(),
      };
}

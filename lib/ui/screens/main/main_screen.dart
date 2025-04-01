import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/ui/screens/home/home_page.dart';
import 'package:chessudoku/ui/screens/test/test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  MainScreen({super.key});

  final List<Widget> _pages = [
    const HomePage(),
    const TestPage(),
    const TestPage(),
    const TestPage(),
    const TestPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    return Scaffold(
      body: _pages[navigationState.selectedIndex],
    );
  }
}
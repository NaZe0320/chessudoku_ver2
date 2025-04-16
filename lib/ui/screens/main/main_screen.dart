import 'package:chessudoku/core/di/nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chessudoku/core/routes/app_routes.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationNotifierProvider).selectedIndex;
    final intent = ref.read(navigationIntentProvider);
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: AppRoutes.navigationPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          intent.selectTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: '퍼즐',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '소셜',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '상점',
          ),
        ],
      ),
    );
  }
}

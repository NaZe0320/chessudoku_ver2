import 'package:chessudoku/core/di/providers.dart';
import 'package:chessudoku/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final navigationIntent = ref.read(navigationIntentProvider);

    return Scaffold(
      body: AppRoutes.navigationPages[navigationState.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.selectedIndex,
        onTap: (index) {
          navigationIntent.selectTab(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: '퍼즐'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '소셜'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '상점',
          ),
        ],
      ),
    );
  }
}

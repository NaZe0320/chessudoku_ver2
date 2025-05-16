import 'package:chessudoku/ui/common/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:chessudoku/ui/screens/home/home_screen.dart';
import 'package:chessudoku/ui/screens/pack/pack_screen.dart';
import 'package:chessudoku/ui/screens/test/test_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 각 탭에 해당하는 스크린들
  final List<Widget> _screens = [
    const HomeScreen(),
    const PackScreen(),
    const TestPage(),
    const TestPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 현재 선택된 인덱스에 따라 화면 전환
          _screens[_currentIndex],

          // 바텀 네비게이션을 화면 하단에 배치
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavItem(icon: Icons.home, label: '홈'),
                BottomNavItem(icon: Icons.grid_view, label: '퍼즐 팩'),
                BottomNavItem(icon: Icons.people, label: '친구'),
                BottomNavItem(icon: Icons.person, label: '프로필'),
              ],
              onCenterButtonPressed: () {
                // 새 퍼즐 생성 바텀 시트 표시
                _showCreatePuzzleBottomSheet();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePuzzleBottomSheet() {
    // 퍼즐 생성 바텀 시트 구현
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: const Text('퍼즐 생성임 아무튼 생성임'),
      ),
    );
  }
}

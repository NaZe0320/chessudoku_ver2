import 'package:chessudoku/ui/common/widgets/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:chessudoku/ui/screens/home/home_screen.dart';
import 'package:chessudoku/ui/screens/pack/pack_screen.dart';
import 'package:chessudoku/ui/screens/profile/profile_screen.dart';
import 'package:chessudoku/ui/screens/puzzle/create_puzzle_bottom_sheet.dart';
import 'package:chessudoku/ui/screens/test/test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);

    // 키보드가 올라왔는지 확인
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // 각 탭에 해당하는 스크린들
    final screens = [
      const HomeScreen(),
      const PackScreen(),
      const TestPage(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // 현재 선택된 인덱스에 따라 화면 전환 (하단 패딩 추가)
          Padding(
            padding: EdgeInsets.only(
              bottom: isKeyboardVisible ? 0 : 60, // 키보드가 올라오면 패딩 제거
            ),
            child: screens[currentIndex.value],
          ),

          // 바텀 네비게이션을 화면 하단에 배치 (키보드가 올라오면 숨김)
          if (!isKeyboardVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                selectedIndex: currentIndex.value,
                onItemSelected: (index) {
                  currentIndex.value = index;
                },
                items: [
                  BottomNavItem(icon: Icons.home, label: '홈'),
                  BottomNavItem(icon: Icons.grid_view, label: '퍼즐 팩'),
                  BottomNavItem(icon: Icons.people, label: '친구'),
                  BottomNavItem(icon: Icons.person, label: '프로필'),
                ],
                onCenterButtonPressed: () {
                  // 새 퍼즐 생성 바텀 시트 표시
                  showCreatePuzzleBottomSheet(context);
                },
              ),
            ),
        ],
      ),
    );
  }
}

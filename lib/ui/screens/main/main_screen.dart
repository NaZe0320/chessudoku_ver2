import 'package:chessudoku/ui/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 키보드가 올라왔는지 확인
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 현재 선택된 인덱스에 따라 화면 전환 (하단 패딩 추가)
          Padding(
            padding: EdgeInsets.only(
              bottom: isKeyboardVisible ? 0 : 60, // 키보드가 올라오면 패딩 제거
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: [
          Text('오늘의 도전전'),
          SizedBox(height: 160),
          Text('연속 기록록'),
          SizedBox(height: 160),
          Text('최근 활동동'),
          SizedBox(height: 160),
          Text('주간 리더보드'),
          SizedBox(height: 160),
        ],
      ),
    );
  }
}

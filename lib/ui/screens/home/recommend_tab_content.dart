import 'package:flutter/material.dart';

class RecommendTabContent extends StatelessWidget {
  const RecommendTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: [
          Text('당신을 위한 추천'),
          SizedBox(height: 160),
          Text('체스 마스터 팩'),
          SizedBox(height: 16),
          Text('난이도: 어려움 • 30 퍼즐'),
          SizedBox(height: 160),
          Text('트렌딩'),
          SizedBox(height: 160),
        ],
      ),
    );
  }
}

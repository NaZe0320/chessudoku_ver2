import 'package:flutter/material.dart';

class ChallengeTabContent extends StatelessWidget {
  const ChallengeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        spacing: 16,
        children: [
          Text('일일 도전'),
          Text('난이도: 보통'),
          Text('비숍과 나이트 기물이 포함된 퍼즐을 완료하세요.'),
          Text('보상: 50 포인트'),
          SizedBox(height: 144),
          Text('주간 도전'),
          Text('난이도: 어려움'),
          Text('10분 이내에 어려운 퍼즐 5개를 연속으로 완료하세요.'),
          Text('보상: 200 포인트'),
        ],
      ),
    );
  }
}

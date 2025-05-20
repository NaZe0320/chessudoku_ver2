import 'package:flutter/material.dart';

class HistoryTabContent extends StatelessWidget {
  const HistoryTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        spacing: 16,
        children: [
          Text('통계 요약'),
          Text('완료한 퍼즐: 152'),
          Text('평균 시간: 5:42'),
          Text('성공률: 86%'),
          SizedBox(height: 24),
          Text('통계 그래프'),
          SizedBox(height: 144),
          Text('최근 기록'),
          SizedBox(height: 144),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RecommendPackTabContent extends StatelessWidget {
  const RecommendPackTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: [
          Text('추천 팩'),
        ],
      ),
    );
  }
}

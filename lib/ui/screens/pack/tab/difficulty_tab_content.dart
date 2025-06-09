import 'package:flutter/material.dart';

class DifficultyPackTabContent extends StatelessWidget {
  const DifficultyPackTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: [
          Text('난이도별 팩'),
        ],
      ),
    );
  }
}

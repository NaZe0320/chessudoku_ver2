import 'package:flutter/material.dart';

class ProgressPackTabContent extends StatelessWidget {
  const ProgressPackTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: [
          Text('진행 중인 팩'),
        ],
      ),
    );
  }
}

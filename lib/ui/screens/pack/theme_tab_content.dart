import 'package:flutter/material.dart';

class ThemePackTabContent extends StatelessWidget {
  const ThemePackTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        children: [
          Text('테마별 팩'),
        ],
      ),
    );
  }
}

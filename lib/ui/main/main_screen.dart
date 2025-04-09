import 'package:flutter/material.dart';
import 'package:chessudoku/data/models/user.dart';

class MainScreen extends StatelessWidget {
  final User user;

  const MainScreen(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Sudoku'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('메인 화면'), // TODO: 메인 화면 구현
      ),
    );
  }
}

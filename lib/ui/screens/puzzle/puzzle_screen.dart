import 'package:flutter/material.dart';
import 'package:chessudoku/data/models/cell_content.dart';

class PuzzleScreen extends StatelessWidget {
  final List<List<CellContent>> board;

  const PuzzleScreen({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('체스도쿠 게임'),
      ),
      body: Center(
        child: Text(
            '생성된 퍼즐을 표시할 화면입니다. (보드 사이즈: ${board.length}x${board[0].length})'),
      ),
    );
  }
}

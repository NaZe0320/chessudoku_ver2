import 'package:flutter/material.dart';

class ChessPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 24;

    final Paint paint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        if ((x ~/ cellSize + y ~/ cellSize) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ChessPatternPainter oldDelegate) => false;
}

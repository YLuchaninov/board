import 'package:flutter/material.dart';

import '../../../index.dart';

class Painter extends CustomPainter {
  final Color color;

  Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final vPaint = Paint()
      ..color = color
      ..shader = LinearGradient(
        colors: [color, Colors.transparent],
        stops: [0.5, 0.5],
        tileMode: TileMode.repeated,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, 10, 10))
      ..strokeWidth = 1.3;

    for (double x = 0; x < size.width; x += COLUMN_WIDTH) {
      final p1 = Offset(x, 0);
      final p2 = Offset(x, size.height);
      canvas.drawLine(p1, p2, vPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vPaint = Paint()
      ..color = Colors.black54
      ..shader = LinearGradient(
        colors: [Colors.black54, Colors.transparent],
        stops: [0.5, 0.5],
        tileMode: TileMode.repeated,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, 10, 10))
      ..strokeWidth = 0.7;

    for (double x = 0; x < size.width; x += 100) {
      final p1 = Offset(x, 0);
      final p2 = Offset(x, size.height);
      canvas.drawLine(p1, p2, vPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

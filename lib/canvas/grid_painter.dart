import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final Color? color;
  final double cellWidth;
  final double cellHeight;
  final double strokeWidth;
  final double dotLength;

  GridPainter({
    this.color,
    required this.cellWidth,
    required this.cellHeight,
    required this.dotLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _color = color ?? Colors.black;

    // draw vertical lines
    final vPaint = Paint()
      ..color = _color
      ..shader = LinearGradient(
        colors: [_color, Colors.transparent],
        stops: [0.5, 0.5],
        tileMode: TileMode.repeated,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, dotLength, dotLength))
      ..strokeWidth = strokeWidth;

    for (double x = 0; x < size.width; x += cellWidth) {
      final p1 = Offset(x, 0);
      final p2 = Offset(x, size.height);
      canvas.drawLine(p1, p2, vPaint);
    }

    // draw horizontal lines
    final hPaint = Paint()
      ..color = _color
      ..shader = LinearGradient(
        colors: [_color, Colors.transparent],
        stops: [0.5, 0.5],
        tileMode: TileMode.repeated,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, dotLength, dotLength))
      ..strokeWidth = strokeWidth;

    for (double y = 0; y < size.height; y += cellHeight) {
      final p1 = Offset(0, y);
      final p2 = Offset(size.width, y);
      canvas.drawLine(p1, p2, hPaint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

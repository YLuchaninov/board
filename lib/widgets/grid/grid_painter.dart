import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final bool isVisible;
  final Color color;
  final double cellWidth;
  final double cellHeight;
  final double strokeWidth;
  final double dotLength;

  GridPainter({
    @required this.isVisible,
    @required this.color,
    @required this.cellWidth,
    @required this.cellHeight,
    this.dotLength = 10,
    this.strokeWidth = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isVisible) return;

    // draw vertical lines
    final vPaint = Paint()
      ..color = color
      ..shader = LinearGradient(
        colors: [color, Colors.transparent],
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

    // draw vertical lines
    final hPaint = Paint()
      ..color = color
      ..shader = LinearGradient(
        colors: [color, Colors.transparent],
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

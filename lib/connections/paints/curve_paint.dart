import 'package:flutter/material.dart';

import '../connection_painter.dart';
import '../connection.dart';

class LinePainter extends ConnectionPainter {
  final double? strokeWidth;
  final Color? color;

  LinePainter({this.strokeWidth, this.color});

  @override
  PainterData getPaintDate<T>(
    Connection<T>? connection,
    Offset start,
    Offset end,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 1.0
      ..color = connection != null
          ? (color ?? Colors.blue)
          : Colors.lightGreen; // todo setup color

    // todo make curve path
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    return PainterData(path, paint);
  }
}

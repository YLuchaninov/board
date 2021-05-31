import 'package:flutter/material.dart';

import '../connection_painter.dart';
import '../connection.dart';

class CurvePainter extends ConnectionPainter {
  final double? strokeWidth;
  final Color? color;

  CurvePainter({this.strokeWidth, this.color});

  @override
  PainterData getPaintDate<T>(
    Connection<T>? connection,
    Offset start,
    Offset end,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 2.0
      ..color = connection != null
          ? (color ?? Colors.blue)
          : Colors.lightGreen; // todo setup color

    // start should be before end
    if (start.dx > end.dx) {
      Offset tmp = end;
      end = start;
      start = tmp;
    }

    // todo make curve path
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      start.dx + 150,
      start.dy,
      end.dx - 150,
      end.dy,
      end.dx,
      end.dy,
    );

    return PainterData(path, paint);
  }
}

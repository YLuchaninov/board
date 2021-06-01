import 'package:flutter/material.dart';

import 'interface.dart';
import '../connection.dart';

class LinePainter extends ConnectionPainter {
  final double? strokeWidth;
  final Color? color;

  LinePainter({this.strokeWidth, this.color});

  @override
  PainterData getPaintDate<T>({
    required Connection<T>? connection,
    required Offset start,
    required Offset end,
    required Alignment? startAlignment,
    required Alignment? endAlignment,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth ?? 2.0
      ..color = connection != null
          ? (color ?? Colors.red)
          : Colors.orangeAccent; // todo change color

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    return PainterData(path, paint);
  }
}

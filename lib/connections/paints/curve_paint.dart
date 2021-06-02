import 'package:flutter/material.dart';

import 'interface.dart';
import '../connection.dart';

const double _kForce = 150;

class CurvePainter extends ConnectionPainter {
  final double? strokeWidth;
  final Color? color;

  CurvePainter({this.strokeWidth, this.color});

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
          : Colors.deepOrangeAccent; // todo setup color

    // make curve path
    Offset controlStart = start;
    if (startAlignment != null)
      controlStart += Offset(_kForce * startAlignment.x, _kForce * startAlignment.y);

    Offset controlEnd = end;
    if (endAlignment != null)
      controlEnd += Offset(_kForce * endAlignment.x, _kForce * endAlignment.y);

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      controlStart.dx,
      controlStart.dy,
      controlEnd.dx,
      controlEnd.dy,
      end.dx,
      end.dy,
    );

    return PainterData(path, paint);
  }
}

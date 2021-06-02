import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../connection.dart';
import '../../core/types.dart';
import 'curve_paint.dart';

class DebugPainter<T> extends CustomPainter {
  final List<AnchorConnection<T>> connections;
  final double tapTolerance;
  final PainterBuilder<T>? painterBuilder;

  DebugPainter({
    required this.connections,
    required this.painterBuilder,
    required this.tapTolerance,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    connections.forEach((connection) {
      final painter =
          painterBuilder?.call(connection.connection) ?? CurvePainter();
      final data = painter.getPaintDate<T>(
        connection: connection.connection,
        start: connection.start,
        end: connection.end,
        startAlignment: connection.startAlignment,
        endAlignment: connection.endAlignment,
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = data.paint.strokeWidth + tapTolerance
        ..color = Colors.red.withOpacity(0.5);

      canvas.drawPath(data.path, paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

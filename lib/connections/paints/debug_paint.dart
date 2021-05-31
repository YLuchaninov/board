import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../connection_painter.dart';
import '../connection.dart';

class DebugPainter<T> extends CustomPainter {
  final List<AnchorConnection<T>> connections;
  final ConnectionPainter painter;
  final double tapTolerance;

  DebugPainter({
    required this.connections,
    required this.painter,
    required this.tapTolerance,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    connections.forEach((connection) {
      final data = painter.getPaintDate<T>(
        connection.connection,
        connection.start,
        connection.end,
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

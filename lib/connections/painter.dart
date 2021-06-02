import 'package:flutter/material.dart';

import 'connection.dart';
import '../core/types.dart';
import 'paints/curve_paint.dart';

class PositionPainter<T> extends CustomPainter {
  final Offset? start;
  final Offset? end;
  final Iterable<AnchorConnection<T>> connections;
  final bool enable;
  final PainterBuilder<T>? painterBuilder;

  PositionPainter({
    required this.connections,
    required this.start,
    required this.end,
    required this.enable,
    required this.painterBuilder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // draw connections
    for (var connection in connections) {
      final painter = painterBuilder?.call(connection.connection) ?? CurvePainter();
      final data = painter.getPaintDate<T>(
        connection: connection.connection,
        start: connection.start,
        end: connection.end,
        startAlignment: connection.startAlignment,
        endAlignment: connection.endAlignment,
      );
      canvas.drawPath(data.path, data.paint);
    }

    if (!enable) return;

    // draw dragging connection
    final painter = CurvePainter(); // todo painterBuilder?.call(null) ??
    final data = painter.getPaintDate<T>(
      connection: null,
      start: start ?? Offset.zero,
      end: end ?? Offset.zero,
      startAlignment: null, // todo
      endAlignment: null, // todo
    );
    canvas.drawPath(data.path, data.paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

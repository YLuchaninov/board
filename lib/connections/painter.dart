import 'package:board/board.dart';
import 'package:flutter/material.dart';

import '../connections/connection.dart';

class PositionPainter<T> extends CustomPainter {
  final Offset? start;
  final Offset? end;
  final Iterable<AnchorConnection<T>> connections;
  final bool enable;
  final ConnectionPainter connectionPainter;

  PositionPainter({
    required this.connections,
    required this.start,
    required this.end,
    required this.enable,
    required this.connectionPainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // draw connections
    for (var connection in connections) {
      final data = connectionPainter.getPaintDate<T>(
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
    final data = connectionPainter.getPaintDate<T>(
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

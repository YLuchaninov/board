import 'package:flutter/material.dart';

import '../connections/connection.dart';

class PositionPainter extends CustomPainter {
  final List<Offset> positions;
  final Offset? start;
  final Offset? end;
  final Iterable<AnchorConnection> connections;
  final bool enable;

  PositionPainter({
    required this.positions,
    required this.connections,
    required this.start,
    required this.end,
    required this.enable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2;

    for (var connection in connections) {
      canvas.drawLine(connection.start, connection.end, drawPaint);
    }

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    if (!enable) return;
    canvas.drawLine(start ?? Offset.zero, end ?? Offset.zero, paint);

    // todo remove positions drawing
    final _paint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 2;

    positions.forEach((position) {
      canvas.drawLine(position, position + Offset(30, 0), _paint);
      canvas.drawLine(position, position + Offset(0, 30), _paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

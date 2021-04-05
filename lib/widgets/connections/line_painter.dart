import 'package:flutter/material.dart';
import 'connection.dart';

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final List<Connection> connections;
  final bool enable;

  LinePainter({
    @required this.start,
    @required this.end,
    @required this.connections,
    @required this.enable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!enable) return;

    final paint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2;

    canvas.drawLine(start, end, paint);

    connections.forEach((connection) {
      canvas.drawLine(connection.start, connection.end, paint);
    });
  }

  @override
  bool shouldRepaint(LinePainter oldPainter) =>
      oldPainter.start != start ||
      oldPainter.end != end ||
      connections.length != oldPainter.connections.length;
}

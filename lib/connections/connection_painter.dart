import 'package:flutter/material.dart';

import 'connection.dart';

abstract class ConnectionPainter {
  PainterData getPaintDate<T>(
    Connection<T>? connection,
    Offset start,
    Offset end,
  );
}

class PainterData {
  final Path path;
  final Paint paint;

  PainterData(this.path, this.paint);
}

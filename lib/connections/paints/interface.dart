import 'package:flutter/material.dart';

import '../connection.dart';

abstract class ConnectionPainter {
  PainterData getPaintDate<T>({
    // todo make it simple
    required Connection<T>? connection,
    required Offset start,
    required Offset end,
    required Alignment? startAlignment,
    required Alignment? endAlignment,
  });
}

class PainterData {
  final Path path;
  final Paint paint;

  PainterData(this.path, this.paint);
}

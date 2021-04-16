import 'package:flutter/material.dart';

import 'utils.dart';

class AnchorConnection {
  final Offset start;
  final Offset end;

  AnchorConnection({this.start, this.end});
}

class Connection<T> {
  final T start;
  final T end;

  Connection(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      other is Connection<T> && other.start == start && other.end == end;

  @override
  int get hashCode => hash2(start, end);
}


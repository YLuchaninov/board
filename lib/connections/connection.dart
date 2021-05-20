import 'package:flutter/material.dart';

class AnchorConnection {
  final Offset start;
  final Offset end;

  AnchorConnection({
    required this.start,
    required this.end,
  });
}

class Connection<T> {
  final T start;
  final T end;

  Connection(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      other is Connection<T> && other.start == start && other.end == end;

  @override
  int get hashCode => hashValues(start, end);
}

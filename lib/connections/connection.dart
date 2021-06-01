import 'package:flutter/material.dart';

class AnchorConnection<T> {
  final Offset start;
  final Offset end;
  final Connection<T> connection;
  final Alignment? startAlignment;
  final Alignment? endAlignment;

  AnchorConnection({
    required this.start,
    required this.end,
    required this.connection,
    required this.startAlignment, // todo make it simple
    required this.endAlignment, // todo make it simple
  });
}

class Connection<T> {
  final T start;
  final T end;
  final dynamic metaData;

  Connection(this.start, this.end, {this.metaData});

  @override
  bool operator ==(Object other) =>
      other is Connection<T> && other.start == start && other.end == end;

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() => 'Connection: $start - $end';
}

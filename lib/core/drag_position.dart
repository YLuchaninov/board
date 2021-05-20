import 'package:flutter/material.dart';

class DragPosition {
  final int index;
  final Offset? offset;

  DragPosition({required this.index, this.offset});

  @override
  int get hashCode => hashValues(index, offset);

  @override
  bool operator ==(Object other) =>
      other is DragPosition && index == other.index && offset == other.offset;
}

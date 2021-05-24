import 'package:flutter/material.dart';

class DragPosition<T> {
  final int index;
  final Offset? offset;
  final Map<T, Offset> anchors;

  DragPosition({required this.index, this.offset, required this.anchors});

  @override
  int get hashCode => hashValues(index, offset);

  @override
  bool operator ==(Object other) =>
      other is DragPosition<T> && index == other.index && offset == other.offset;
}

import 'package:flutter/material.dart';

class RulerPosition {
  final Offset position;
  final double scale;

  RulerPosition({required this.position, required this.scale});

  @override
  bool operator ==(Object other) =>
      other is RulerPosition &&
          other.position == position &&
          other.scale == scale;

  @override
  int get hashCode => hashValues(position, scale);

  @override
  String toString() => 'ScrollPosition[$position - scale:$scale]';
}

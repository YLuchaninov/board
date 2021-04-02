import 'package:flutter/material.dart';

class EmptyPainter extends CustomPainter {
   @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(_) => false;
}

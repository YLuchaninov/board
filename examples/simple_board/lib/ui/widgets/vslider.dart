import 'package:flutter/material.dart';

class VSlider extends StatelessWidget {
  final double value;
  final ValueChanged onChanged;
  final double min;
  final double max;
  final int divisions;

  const VSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.divisions,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: Slider(
        min: min,
        max: max,
        divisions: divisions,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

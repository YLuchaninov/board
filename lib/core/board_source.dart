import 'package:flutter/material.dart';

class BoardSource<H extends Object> extends StatelessWidget {
  final Widget source;
  final Widget feedback;
  final H? boardData;
  final double? scale;

  const BoardSource({
    Key? key,
    required this.source,
    required this.feedback,
    this.boardData,
    this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<H>(
      maxSimultaneousDrags: 1,
      feedback: Material(
        child: Transform.scale(
          scale: scale ?? 1,
          child: feedback,
        ),
        color: Colors.transparent,
      ),
      child: source,
      data: boardData,
    );
  }
}

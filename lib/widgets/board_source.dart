import 'package:flutter/material.dart';

import 'grid/handler.dart';

class BoardSource extends StatelessWidget {
  final Widget source;
  final Widget feedback;
  final Handler boardData;

  const BoardSource({
    Key key,
    @required this.source,
    @required this.feedback,
    this.boardData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Handler>(
      feedback: Material(child: feedback, color: Colors.transparent),
      child: source,
      data: boardData,
    );
  }
}

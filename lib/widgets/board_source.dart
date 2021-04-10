import 'package:flutter/material.dart';

import 'grid/handler.dart';

class BoardSource<H> extends StatelessWidget {
  final Widget source;
  final Widget feedback;
  final H boardData;

  const BoardSource({
    Key key,
    @required this.source,
    @required this.feedback,
    this.boardData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<H>(
      feedback: Material(child: feedback, color: Colors.transparent),
      child: source,
      data: boardData,
    );
  }
}

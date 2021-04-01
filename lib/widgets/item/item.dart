import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../grid/handler.dart';

class BoardItem extends StatefulWidget {
  final ItemHandler handler;
  final Widget child;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const BoardItem({
    Key key,
    this.handler,
    this.scale,
    this.child,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  BoardItemState createState() => BoardItemState();
}

class BoardItemState extends State<BoardItem> {
  Offset offset = Offset.zero;
  Size size = Size.zero;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(), //constructor
          (TapGestureRecognizer instance) => instance.onTap = widget.onTap,
        ),
        LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(), //constructor
              (LongPressGestureRecognizer instance) => instance.onLongPress = widget.onLongPress,
        )
      },
      child: Listener(
        onPointerDown: (event) {
          setState(() {
            final RenderBox renderObject = context.findRenderObject();
            size = renderObject.size;
            offset = event.localPosition;
          });
        },
        child: Draggable<Handler>(
          childWhenDragging: Container(),
          feedback: Transform.translate(
            offset: Offset(
              size.width * (widget.scale - 1) / 2,
              size.height * (widget.scale - 1) / 2,
            ),
            child: Transform.scale(
              origin: offset,
              scale: widget.scale,
              child: Material(
                child: Opacity(child: widget.child, opacity: 0.8),
                color: Colors.transparent,
              ),
            ),
          ),
          child: widget.child,
          data: widget.handler,
        ),
      ),
    );
  }
}

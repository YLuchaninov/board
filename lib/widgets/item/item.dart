import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BoardItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool enable;
  final Offset offset;
  final ValueChanged<Offset> onPositionChange;

  const BoardItem({
    Key key,
    @required this.child,
    @required this.onTap,
    @required this.onLongPress,
    @required this.enable,
    @required this.offset,
    @required this.onPositionChange,
  })  : assert(child is PreferredSizeWidget,
            'Board child should be PreferredSizeWidget'),
        super(key: key);

  @override
  BoardItemState createState() => BoardItemState();
}

class BoardItemState extends State<BoardItem> {
  Size get size => (widget.child as PreferredSizeWidget).preferredSize;
  Offset position;
  Offset panOffset;

  @override
  void initState() {
    position = widget.offset;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BoardItem oldWidget) {
    position = widget.offset;
    super.didUpdateWidget(oldWidget);
  }

  Widget buildChild(BuildContext context) {
    if (!widget.enable) return widget.child;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        widget.onLongPress();
      },
      onPanDown: (event) => panOffset = event.localPosition,
      onPanEnd: (event) {
        if (widget.enable) {
          widget.onPositionChange(position);
        }
      },
      onPanUpdate: (event) {
        panOffset = event.localPosition;
        if (widget.enable)
          setState(() {
            position += event.delta;
          });
      },
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: buildChild(context),
    );
  }
}

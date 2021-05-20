import 'package:flutter/material.dart';

class BoardItem extends StatefulWidget {
  final bool enabled;
  final Widget child;
  final Offset position;
  final ValueChanged<Offset> onChange;
  final ValueChanged<Offset> onDragging;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const BoardItem({
    Key? key,
    required this.enabled,
    required this.child,
    required this.position,
    required this.onChange,
    required this.onDragging,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  BoardItemState createState() => BoardItemState();
}

class BoardItemState extends State<BoardItem> {
  Offset _position = Offset.zero;

  Offset panOffset = Offset.zero;

  @override
  void initState() {
    _position = widget.position;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BoardItem oldWidget) {
    _position = widget.position;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onPanDown:
            widget.enabled ? (event) => panOffset = event.localPosition : null,
        onPanUpdate: widget.enabled
            ? (event) {
                panOffset = event.localPosition;
                setState(() {
                  _position += event.delta;
                  widget.onDragging(_position);
                });
              }
            : null,
        onPanEnd: widget.enabled
            ? (event) {
                widget.onChange(_position);
              }
            : null,
        child: widget.child,
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BoardItem extends StatefulWidget {
  static _RootNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RootNotifier>();

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
  Offset panOffset;
  ValueNotifier<Offset> position = ValueNotifier(Offset.zero);

  @override
  void initState() {
    position.value = widget.offset;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BoardItem oldWidget) {
    position.value = widget.offset;
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
          widget.onPositionChange(position.value);
        }
      },
      onPanUpdate: (event) {
        panOffset = event.localPosition;
        if (widget.enable)
          setState(() {
            position.value += event.delta;
          });
      },
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.value.dy,
      left: position.value.dx,
      child: _RootNotifier(
        position: position,
        child: buildChild(context),
      ),
    );
  }
}

class _RootNotifier extends InheritedWidget {
  final ValueNotifier<Offset> position;

  _RootNotifier({
    Key key,
    @required Widget child,
    @required this.position,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_RootNotifier oldWidget) => false;
}

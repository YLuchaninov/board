import 'package:flutter/material.dart';

import 'position.dart';

class BoardBar extends StatefulWidget {
  final ValueNotifier<RulerPosition> scroller;
  final double contentSize;
  final Axis direction;

  const BoardBar({
    Key? key,
    required this.scroller,
    required this.contentSize,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  _BoardBarState createState() => _BoardBarState();
}

class _BoardBarState extends State<BoardBar> {
  late double x, y, scale;

  @override
  void initState() {
    scale = widget.scroller.value.scale;
    x = widget.scroller.value.position.dx;
    y = widget.scroller.value.position.dy;
    widget.scroller.addListener(_onScroll);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BoardBar oldWidget) {
    widget.scroller.addListener(_onScroll);
    oldWidget.scroller.removeListener(_onScroll);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.scroller.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() => setState(() {
        scale = widget.scroller.value.scale;
        x = widget.scroller.value.position.dx;
        y = widget.scroller.value.position.dy;
      });

  Widget _wrapper(Widget child, double position, double size) {
    if (widget.direction == Axis.vertical)
      return Positioned(
        right: 0,
        width: 3,
        top: position,
        height: size,
        child: child,
      );
    return Positioned(
      left: position,
      width: size,
      top: 0,
      height: 3,
      child: child,
    );
  }

  List<double> _getConstraints(BoxConstraints constraints) {
    final result = <double>[0, 0];
    if (widget.contentSize <= 0) return result;

    if (widget.direction == Axis.vertical) {
      result[0] =
          constraints.maxHeight * constraints.maxHeight / widget.contentSize;
      result[1] = y *
          (constraints.maxHeight - result[0]) /
          (widget.contentSize - constraints.maxHeight);
    } else {
      result[0] =
          constraints.maxWidth * constraints.maxWidth / widget.contentSize;
      result[1] = x *
          (constraints.maxWidth - result[0]) /
          (widget.contentSize - constraints.maxWidth);
    }

    if (result[0] < 20) result[0] = 20;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final barConstraints = _getConstraints(constraints);
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                _wrapper(
                  Visibility(
                    visible: barConstraints[0] <
                        (widget.direction == Axis.vertical
                            ? constraints.maxHeight
                            : constraints.maxWidth),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor.withOpacity(0.4),
                        borderRadius: BorderRadius.all(Radius.circular(1.5)),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  barConstraints[1],
                  barConstraints[0],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

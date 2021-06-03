import 'package:flutter/material.dart';

import 'position.dart';

class Ruler extends StatefulWidget {
  final ValueNotifier<RulerPosition> scroller;
  final double contentWith;
  final Widget child;

  const Ruler({
    Key? key,
    required this.scroller,
    required this.contentWith,
    required this.child,
  }) : super(key: key);

  @override
  _RulerState createState() => _RulerState();
}

class _RulerState extends State<Ruler> {
  late double scale;
  late double x;

  @override
  void initState() {
    scale = widget.scroller.value.scale;
    x = widget.scroller.value.position.dx;
    widget.scroller.addListener(_onScroll);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Ruler oldWidget) {
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
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: -x * scale,
                  width: widget.contentWith * scale,
                  height: constraints.maxHeight,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: widget.child,
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: 200,
                  child: Center(
                      child: Text('${x.toInt()} - ${(x + constraints.maxWidth * scale).toInt()}')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

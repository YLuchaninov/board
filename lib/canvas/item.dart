import 'package:flutter/material.dart';

import '../core/types.dart';

const _AnimationDuration = 1000;

class BoardItem extends StatefulWidget {
  final bool enabled;
  final Widget child;
  final Offset position;
  final ValueChanged<Offset> onChange;
  final ValueChanged<Offset> onDragging;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final AnchorSetter? anchorSetter;

  const BoardItem({
    Key? key,
    required this.enabled,
    required this.child,
    required this.position,
    required this.onChange,
    required this.onDragging,
    required this.onTap,
    required this.onLongPress,
    required this.anchorSetter,
  }) : super(key: key);

  @override
  BoardItemState createState() => BoardItemState();
}

class BoardItemState extends State<BoardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  Animation<Offset>? animation;
  Offset _position = Offset.zero;
  Offset panOffset = Offset.zero;

  @override
  void initState() {
    _position = widget.position;
    animationController = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: _AnimationDuration),
      vsync: this,
    );
    animationController.addListener(_onAnimation);
    _stickToGrid(_position);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BoardItem oldWidget) {
    if(_position != widget.position) {
      _position = widget.position;
      _stickToGrid(_position);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController.removeListener(_onAnimation);
    animationController.dispose();
    super.dispose();
  }

  _onAnimation() => setState(() {
        _position = animation!.value;
      });

  _onPanDownBuilder() {
    if (!widget.enabled) return null;
    return (event) {
      if (animation is Animation) {
        animation = null;
        animationController.stop();
      }
      panOffset = event.localPosition;
    };
  }

  _onPanEndBuilder() {
    if (!widget.enabled) return null;
    return (event) {
      widget.onChange(_position);
      _stickToGrid(_position);
    };
  }

  _onPanUpdateBuilder() {
    if (!widget.enabled) return null;
    return (event) {
      panOffset = event.localPosition;
      setState(() {
        _position += event.delta;
        widget.onDragging(_position);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onPanDown: _onPanDownBuilder(),
        onPanUpdate: _onPanUpdateBuilder(),
        onPanEnd: _onPanEndBuilder(),
        child: widget.child,
      ),
    );
  }

  _stickToGrid(Offset from) {
    if (widget.anchorSetter is AnchorSetter) {
      final to = widget.anchorSetter?.call(from);
      if(_position != to) {
        animation =
            Tween<Offset>(begin: from, end: to).animate(animationController);
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          animationController.forward(from: 0).whenComplete(() {
            animation = null;
            widget.onChange(to!);
          });
        });
      }
    }
  }
}

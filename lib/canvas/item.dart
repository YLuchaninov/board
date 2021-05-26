import 'package:flutter/material.dart';

import '../core/types.dart';
import '../connections/item_interceptor.dart';

const _AnimationDuration = 100;

class BoardItem<T> extends StatefulWidget {
  static ItemInterceptor<T>? of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ItemInterceptor<T>>();

  final bool enabled;
  final Widget child;
  final Offset position;
  final ValueChanged<Offset> onChange;
  final OnDragging<T> onDragging;
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
  BoardItemState<T> createState() => BoardItemState<T>();
}

class BoardItemState<T> extends State<BoardItem<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  Animation<Offset>? animation;
  Offset _position = Offset.zero;
  Offset panOffset = Offset.zero;
  final anchors = <T, GetAnchor>{};
  bool requested = false;

  _requestToUpdate() {
    if (!requested) {
      requested = true;
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        final box = context.findRenderObject() as RenderBox;
        final _anchors = <T, Offset>{};
        anchors.forEach((key, value){
          _anchors[key] = box.localToGlobal(anchors[key]!());
        });
        widget.onDragging(_position, _anchors);

        setState(() => requested = false);
      });
    }
  }

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
  void didUpdateWidget(covariant BoardItem<T> oldWidget) {
    if (_position != widget.position) {
      _position = widget.position;
      _stickToGrid(_position);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    anchors.clear();
    animationController.removeListener(_onAnimation);
    animationController.dispose();
    super.dispose();
  }

  _onAnimation() => setState(() {
        _position = animation!.value;
        _requestToUpdate();
      });

  _onPanDownBuilder() {
    if (!widget.enabled) return null;
    return (event) {
      if (animation is Animation) {
        animation = null;
        animationController.stop();
      }
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
      setState(() {
        _position += event.delta;
        _requestToUpdate();
      });
    };
  }

  _registerGetter(T data, GetAnchor getter) {
    anchors[data] = getter;
    _requestToUpdate();
  }

  _unregisterGetter(T data) {
    anchors.remove(data);
    _requestToUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: Listener(
        onPointerDown: (event)=>panOffset = event.localPosition,
        onPointerMove: (event)=>panOffset = event.localPosition,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onPanDown: _onPanDownBuilder(),
          onPanUpdate: _onPanUpdateBuilder(),
          onPanEnd: _onPanEndBuilder(),
          child: ItemInterceptor<T>(
            unregisterGetter: _unregisterGetter,
            registerGetter: _registerGetter,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  _stickToGrid(Offset from) {
    if (widget.anchorSetter is AnchorSetter) {
      final to = widget.anchorSetter?.call(from);
      if (_position != to) {
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

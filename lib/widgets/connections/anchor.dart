import 'package:flutter/material.dart';

import 'path_drawer.dart';
import 'anchor_handler.dart';

class DrawAnchor<T> extends StatefulWidget {
  final Widget child;
  final T data;

  const DrawAnchor({
    Key key,
    @required this.child,
    @required this.data,
  }) : super(key: key);

  @override
  _DrawAnchorState<T> createState() => _DrawAnchorState<T>();
}

class _DrawAnchorState<T> extends State<DrawAnchor<T>> {
  GlobalKey key = GlobalKey();
  bool _requestToRegister = true;

  @override
  void didChangeDependencies() {
    if (_requestToRegister) {
      _requestToRegister = false;
      final interceptor = PathDrawer.of<T>(context);
      interceptor?.register(widget.data, key);
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant DrawAnchor oldWidget) {
    if(widget.data != oldWidget.data) {
      final interceptor = PathDrawer.of<T>(context);
      interceptor?.unregister(widget.data);
      interceptor?.register(widget.data, key);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    final interceptor = PathDrawer.of<T>(context);
    interceptor?.unregister(widget.data);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final anchorData = AnchorData(widget.data);
    final interceptor = PathDrawer.of<T>(context);

    return MetaData(
      key: key,
      metaData: anchorData,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          final renderBox = context.findRenderObject() as RenderBox;
          interceptor.onPointerDown(
            globalTap: event.position,
            data: anchorData,
            size: renderBox.size,
            position: renderBox.localToGlobal(Offset.zero),
          );
        },
        onPointerUp: (PointerUpEvent event) =>
            interceptor.onPointerUp(event.position),
        onPointerCancel: (_) => interceptor.onPointerCancel(),
        child: widget.child,
      ),
    );
  }
}

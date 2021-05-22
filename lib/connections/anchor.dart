import 'package:flutter/material.dart';

import 'painter.dart';
import 'anchor_handler.dart';

class DrawAnchor<T> extends StatefulWidget {
  final Widget child;
  final T data;
  final Offset anchorOffset;

  const DrawAnchor({
    Key? key,
    required this.child,
    required this.data,
    required this.anchorOffset,
  }) : super(key: key);

  @override
  _DrawAnchorState<T> createState() => _DrawAnchorState<T>();
}

class _DrawAnchorState<T> extends State<DrawAnchor<T>> {
  bool requestToInit = true;
  final key = GlobalKey();

  @override
  void didChangeDependencies() {
    if (requestToInit) {
      requestToInit = false;
      final interceptor = ConnectionPainter.of<T>(context);
      interceptor?.register(widget.data, key);
    }

    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    final interceptor = ConnectionPainter.of<T>(context);
    interceptor?.unregister(widget.data);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final anchorData = AnchorData(
      data: widget.data,
      anchorOffset: widget.anchorOffset,
    );
    final interceptor = ConnectionPainter.of<T>(context);

    return MetaData(
      key: key,
      metaData: anchorData,
      child: Listener(
        onPointerDown: (PointerDownEvent event) =>
            interceptor!.onPointerDown(widget.data),
        onPointerUp: (PointerUpEvent event) =>
            interceptor!.onPointerUp(event.position),
        onPointerCancel: (_) => interceptor!.onPointerCancel(),
        child: widget.child,
      ),
    );
  }
}

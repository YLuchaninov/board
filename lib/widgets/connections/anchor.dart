import 'package:flutter/material.dart';

import 'path_drawer.dart';
import 'anchor_handler.dart';
import '../item/item.dart';

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
  bool requestToInit = true;
  final key = GlobalKey();

  @override
  void didChangeDependencies() {
    if (requestToInit) {
      requestToInit = false;
      final interceptor = PathDrawer.of<T>(context);
      interceptor?.register(widget.data, key);

      final positionNotifier = BoardItem.of(context)?.position;
      positionNotifier?.addListener(interceptor?.notify);
    }

    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    final interceptor = PathDrawer.of<T>(context);
    interceptor?.unregister(widget.data);
    final positionNotifier = BoardItem.of(context)?.position;
    positionNotifier?.removeListener(interceptor?.notify);
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
        onPointerDown: (PointerDownEvent event) =>
            interceptor.onPointerDown(widget.data),
        onPointerUp: (PointerUpEvent event) =>
            interceptor.onPointerUp(event.position),
        onPointerCancel: (_) => interceptor.onPointerCancel(),
        child: widget.child,
      ),
    );
  }
}

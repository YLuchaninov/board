import 'package:flutter/material.dart';

import 'path_drawer.dart';
import 'anchor_handler.dart';

class DrawAnchor extends StatelessWidget {
  final Widget child;
  final AnchorData data;

  const DrawAnchor({
    Key key,
    @required this.child,
    @required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interceptor = PathDrawer.of(context);

    return MetaData(
      metaData: data,
      child: Listener(
        onPointerDown: (PointerDownEvent event) =>
            interceptor.onPointerDown(event.position, data),
        onPointerUp: (PointerUpEvent event) =>
            interceptor.onPointerUp(event.position),
        onPointerCancel: (_) => interceptor.onPointerCancel(),
        child: child,
      ),
    );
  }
}

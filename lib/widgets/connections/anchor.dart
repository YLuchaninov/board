import 'package:flutter/material.dart';

import 'path_drawer.dart';
import 'anchor_handler.dart';

class DrawAnchor extends StatelessWidget {
  final Widget child;
  final dynamic data;

  const DrawAnchor({
    Key key,
    @required this.child,
    @required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final anchorData = AnchorData(data);
    final interceptor = PathDrawer.of(context);

    return MetaData(
      metaData: anchorData,
      child: Listener(
        onPointerDown: (PointerDownEvent event) =>
            interceptor.onPointerDown(event.position, anchorData), // todo center
        onPointerUp: (PointerUpEvent event) =>
            interceptor.onPointerUp(event.position), // todo center
        onPointerCancel: (_) => interceptor.onPointerCancel(),
        child: child,
      ),
    );
  }
}

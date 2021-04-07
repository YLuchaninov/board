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
    final key = GlobalKey();

    return MetaData(
      key: key,
      metaData: anchorData,
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          final renderBox = key.currentContext.findRenderObject() as RenderBox;
          interceptor.onPointerDown(
            globalTap: event.position,
            data: anchorData,
            size: renderBox.size,
            position: renderBox.localToGlobal(Offset.zero),
          );
        },
        onPointerUp: (PointerUpEvent event) => interceptor.onPointerUp(event.position),
        onPointerCancel: (_) => interceptor.onPointerCancel(),
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../connections/paints/interface.dart';
import '../connections/connection.dart';

typedef void OnPositionChange(int index, Offset position);
typedef Offset? IndexedPositionBuilder(int index);
typedef void OnAddFromSource<H>(H handler, Offset dropPosition);
typedef Widget IndexedMenuBuilder(
    BuildContext context,
    int index,
    VoidCallback close,
    );
typedef Offset AnchorSetter(Offset position);
typedef void AnchorRegister<T>(T data, GlobalKey key);
typedef void OnConnectionCreate<T>(T startData, T endData);
typedef Offset GetAnchor();
typedef void RegisterAnchorGetter<T>(T data, GetAnchor getter);
typedef void UnregisterAnchorGetter<T>(T data);
typedef void OnDragging<T>(Offset offset, Map<T, Offset> anchors);
typedef void OnIndexedDragging<T>(int index, Offset position, Map<T, Offset> anchors);
typedef void SetAlignment<T>(T data, Alignment? alignment);
typedef ConnectionPainter PainterBuilder<T>(Connection<T> connection);
import 'package:flutter/material.dart';

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
typedef OnConnectionCreate<T>(T startData, T endData);


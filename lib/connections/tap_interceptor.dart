import 'package:flutter/material.dart';

import '../core/types.dart';

class TapInterceptor<T> extends InheritedWidget {
  final ValueChanged<T> onPointerDown;
  final ValueChanged<Offset> onPointerUp;
  final VoidCallback onPointerCancel;

  TapInterceptor({
    Key? key,
    required Widget child,
    required this.onPointerUp,
    required this.onPointerDown,
    required this.onPointerCancel,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(TapInterceptor oldWidget) => false;
}
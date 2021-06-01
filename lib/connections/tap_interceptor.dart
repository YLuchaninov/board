import 'package:flutter/material.dart';

import '../core/types.dart';

class TapInterceptor<T> extends InheritedWidget {
  final ValueChanged<T> onPointerDown;
  final ValueChanged<Offset> onPointerUp;
  final VoidCallback onPointerCancel;
  final SetAlignment<T> setAlignment;
  final ValueChanged<T> unsetAlignment;

  TapInterceptor({
    Key? key,
    required Widget child,
    required this.onPointerUp,
    required this.onPointerDown,
    required this.onPointerCancel,
    required this.setAlignment,
    required this.unsetAlignment,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(TapInterceptor oldWidget) => false;
}
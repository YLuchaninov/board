import 'package:flutter/material.dart';
import '../core/types.dart';

class ItemInterceptor<T> extends InheritedWidget {
  final RegisterAnchorGetter<T> registerGetter;
  final UnregisterAnchorGetter<T> unregisterGetter;

  ItemInterceptor({
    Key? key,
    required Widget child,
    required this.registerGetter,
    required this.unregisterGetter,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ItemInterceptor oldWidget) => false;
}
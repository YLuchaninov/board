import 'package:flutter/material.dart';

class ItemHandler extends Handler {
  final int index;
  final GlobalKey globalKey;

  ItemHandler({this.index, this.globalKey});
}

abstract class Handler {}

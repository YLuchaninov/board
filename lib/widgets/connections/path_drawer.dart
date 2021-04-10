import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'connection.dart';
import 'anchor_handler.dart';
import 'line_painter.dart';
import '../../widgets/board.dart';

typedef PointerNotifier({
  Offset globalTap,
  AnchorData data,
  Size size,
  Offset position,
});

class PathDrawer<T> extends StatefulWidget {
  static _TapInterceptor of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TapInterceptor<T>>();

  final Widget child;
  final bool enable;
  final ValueNotifier<bool> drawSate;
  final double scale;
  final List<MapEntry<T, T>> connections;
  final OnConnectionCreate<T> onConnectionCreate;

  const PathDrawer({
    Key key,
    this.enable,
    this.child,
    this.drawSate,
    this.scale,
    this.connections,
    this.onConnectionCreate,
  }) : super(key: key);

  @override
  _PathDrawerState<T> createState() => _PathDrawerState<T>();
}

class _PathDrawerState<T> extends State<PathDrawer<T>> {
  final connections = <Connection>[];
  final anchors = <T, GlobalKey>{};
  var start = Offset.zero;
  var end = Offset.zero;
  AnchorData startData;

  @override
  initState() {
    // todo
    // todo process connection

    super.initState();
  }

  @override
  didUpdateWidget(PathDrawer oldWidget) {
    // todo
    // todo process connection
    widget.connections?.forEach((element) { });


    super.didUpdateWidget(oldWidget);
  }

  @override
  dispose() {
    connections.clear();
    anchors.clear();
    super.dispose();
  }

  _onPointerDown({
    Offset globalTap,
    AnchorData data,
    Size size,
    Offset position,
  }) {
    if (!widget.enable) return;

    widget.drawSate.value = true;

    final renderObj = context.findRenderObject();
    if (renderObj is RenderBox) {
      // from the anchor center
      position += Offset(size.width / 2, size.height / 2) * widget.scale;
      final tapOffset = renderObj.globalToLocal(position);

      end = start = tapOffset;
      startData = data;

      setState(() {});
    }
  }

  _positionListener(PointerMoveEvent event) {
    if (widget.drawSate.value && widget.enable) {
      setState(() {
        end = event.localPosition;
      });
    }
  }

  _onPointerUp({
    Offset globalTap,
    AnchorData data,
    Size size,
    Offset position,
  }) {
    if (!widget.enable) return;

    widget.drawSate.value = false;

    // if (widget.onConnectionCreate != null &&
    //     widget.onConnectionCreate(startData.data, data.data)) {
    //   // from the anchor center
    //   final renderBox = context.findRenderObject() as RenderBox;
    //   position += Offset(size.width / 2, size.height / 2) * widget.scale;
    //   final tapLocalOffset = renderBox.globalToLocal(position);
    //
    //   // todo
    //   connections.add(Connection(
    //     start: start,
    //     end: tapLocalOffset,
    //   ));
    // }

    widget.onConnectionCreate?.call(startData.data, data.data);

    setState(() {
      end = start = Offset.zero;
      startData = null;
    });
  }

  _onPointerCancel() {
    widget.drawSate.value = false;
    setState(() {
      end = start = Offset.zero;
      startData = null;
    });
  }

  _extractAnchorData(Offset tapOffset) {
    final renderObj = context.findRenderObject();
    if (renderObj is RenderBox) {
      final localOffset = renderObj.globalToLocal(tapOffset);

      final hitTestResult = BoxHitTestResult();
      if (!renderObj.hitTest(hitTestResult, position: localOffset)) return;

      final entry = hitTestResult.path.toList().firstWhere((entry) {
        final target = entry.target;
        if (target is RenderMetaData) {
          final metaData = target.metaData;
          if (metaData is AnchorData) return true;
        }
        return false;
      }, orElse: () => null);

      if (entry != null) {
        final target = entry.target;
        final metaData = (target as RenderMetaData).metaData;
        final metaBox = (target as RenderMetaData);

        _onPointerUp(
          data: metaData,
          position: metaBox.localToGlobal(Offset.zero),
          size: metaBox.size,
          globalTap: tapOffset,
        );
      } else {
        _onPointerCancel();
      }
    }
  }

  registerAnchor(T data, GlobalKey key) {
    anchors[data] = key;
  }

  unregisterAnchor(T data) {
    anchors.remove(data);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: LinePainter(
        enable: widget.enable,
        start: start,
        end: end,
        connections: connections,
      ),
      child: _TapInterceptor<T>(
        child: Listener(
          onPointerMove: _positionListener,
          child: widget.child,
        ),
        onPointerDown: _onPointerDown,
        onPointerUp: _extractAnchorData,
        onPointerCancel: _onPointerCancel,
        register: registerAnchor,
        unregister: unregisterAnchor,
      ),
    );
  }
}

typedef void AnchorRegister<T>(T data, GlobalKey key);

class _TapInterceptor<T> extends InheritedWidget {
  final PointerNotifier onPointerDown;
  final ValueChanged<Offset> onPointerUp;
  final VoidCallback onPointerCancel;
  final AnchorRegister<T> register;
  final ValueChanged<T> unregister;

  _TapInterceptor({
    Key key,
    @required Widget child,
    @required this.onPointerUp,
    @required this.onPointerDown,
    @required this.onPointerCancel,
    @required this.register,
    @required this.unregister,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_TapInterceptor oldWidget) => false;
}

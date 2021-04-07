import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'connection.dart';
import 'anchor_handler.dart';
import 'line_painter.dart';
import '../../board.dart';

typedef PointerNotifier({
  Offset globalTap,
  AnchorData data,
  Size size,
  Offset position,
});

class PathDrawer extends StatefulWidget {
  static _TapInterceptor of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TapInterceptor>();

  final Widget child;
  final bool enable;
  final ValueNotifier<bool> drawSate;
  final ApproveDraw approveDraw;
  final double scale;

  const PathDrawer({
    Key key,
    this.enable,
    this.child,
    this.drawSate,
    this.approveDraw,
    this.scale,
  }) : super(key: key);

  @override
  _PathDrawerState createState() => _PathDrawerState();
}

class _PathDrawerState extends State<PathDrawer> {
  final connections = <Connection>[];
  var start = Offset.zero;
  var end = Offset.zero;
  AnchorData startData;

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

    if (widget.approveDraw != null &&
        widget.approveDraw(startData.data, data.data)) {
      // from the anchor center
      final renderBox = context.findRenderObject() as RenderBox;
      position += Offset(size.width / 2, size.height / 2) * widget.scale;
      final tapLocalOffset = renderBox.globalToLocal(position);

      connections.add(Connection(
        start: start,
        end: tapLocalOffset,
      ));
    }

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
          final dynamic metaData = target.metaData;
          if (metaData is AnchorData) return true;
        }
        return false;
      }, orElse: () => null);

      if (entry != null) {
        final target = entry.target;
        final dynamic metaData = (target as RenderMetaData).metaData;
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

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: LinePainter(
        enable: widget.enable,
        start: start,
        end: end,
        connections: connections,
      ),
      child: _TapInterceptor(
        child: Listener(
          onPointerMove: _positionListener,
          child: widget.child,
        ),
        onPointerDown: _onPointerDown,
        onPointerUp: _extractAnchorData,
        onPointerCancel: _onPointerCancel,
      ),
    );
  }
}

class _TapInterceptor extends InheritedWidget {
  final PointerNotifier onPointerDown;
  final ValueChanged<Offset> onPointerUp;
  final VoidCallback onPointerCancel;

  _TapInterceptor({
    Key key,
    @required Widget child,
    @required this.onPointerUp,
    @required this.onPointerDown,
    @required this.onPointerCancel,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_TapInterceptor oldWidget) => false;
}

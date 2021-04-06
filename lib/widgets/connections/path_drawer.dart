import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'connection.dart';
import 'anchor_handler.dart';
import 'line_painter.dart';
import '../../board.dart';

class PathDrawer extends StatefulWidget {
  static _TapInterceptor of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TapInterceptor>();

  final Widget child;
  final bool enable;
  final ValueNotifier<bool> drawSate;
  final ApproveDraw approveDraw;

  const PathDrawer({
    Key key,
    this.enable,
    this.child,
    this.drawSate,
    this.approveDraw,
  }) : super(key: key);

  @override
  _PathDrawerState createState() => _PathDrawerState();
}

class _PathDrawerState extends State<PathDrawer> {
  final connections = <Connection>[];
  var start = Offset.zero;
  var end = Offset.zero;
  AnchorData startData;

  _onPointerDown(Offset tapOffset, AnchorData data) {
    if (!widget.enable) return;

    widget.drawSate.value = true;

    final renderObj = context.findRenderObject();
    if (renderObj is RenderBox) {
      tapOffset = renderObj.globalToLocal(tapOffset);
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

  _onPointerUp(Offset tapLocalOffset, AnchorData data) {
    if (!widget.enable) return;

    widget.drawSate.value = false;

    if (widget.approveDraw != null &&
        widget.approveDraw(startData.data, data.data)) {
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
      tapOffset = renderObj.globalToLocal(tapOffset);

      final hitTestResult = BoxHitTestResult();
      if (!renderObj.hitTest(hitTestResult, position: tapOffset)) return;

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
        _onPointerUp(tapOffset, (metaData as AnchorData));
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

typedef PointerCallback(Offset offset, AnchorData data);

class _TapInterceptor extends InheritedWidget {
  final PointerCallback onPointerDown;
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

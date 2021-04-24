import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'connection.dart';
import 'anchor_handler.dart';
import 'line_painter.dart';
import '../../widgets/board.dart';

class PathDrawer<T> extends StatefulWidget {
  static _TapInterceptor of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TapInterceptor<T>>();

  final Widget child;
  final bool enable;
  final ValueNotifier<bool> drawSate;
  final double scale;
  final List<Connection<T>> connections;
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
  final anchors = <T, GlobalKey>{};
  Offset start = Offset.zero;
  Offset end = Offset.zero;
  AnchorData startData;
  bool requestToInit = true;

  @override
  void didChangeDependencies() {
    if (requestToInit) {
      requestToInit = false;
      setState(() {});
    }
    super.didChangeDependencies();
  }

  @override
  dispose() {
    anchors.clear();
    super.dispose();
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

  Offset _calculateAnchor(GlobalKey key, RenderBox root) {
    final anchor = key.currentContext.findRenderObject() as RenderBox;
    final offset = anchor.localToGlobal(Offset.zero);
    final size = anchor.size;

    return root.globalToLocal(
        offset + Offset(size.width / 2, size.height / 2) * widget.scale);
  }

  List<AnchorConnection> _calculateConnections() {
    final box = context.findRenderObject() as RenderBox;
    final connections = <AnchorConnection>[];
    widget.connections?.forEach((connection) {
      if (anchors[connection.start] != null &&
          anchors[connection.end] != null) {
        connections.add(AnchorConnection(
          start: _calculateAnchor(anchors[connection.start], box),
          end: _calculateAnchor(anchors[connection.end], box),
        ));
      }
    });

    return connections;
  }

  _onPointerDown(T data) {
    if (!widget.enable) return;

    widget.drawSate.value = true;

    final box = context.findRenderObject();
    end = start = _calculateAnchor(anchors[data], box);
    startData = AnchorData(data);

    setState(() {});
  }

  _register(T data, GlobalKey key) {
    anchors[data] = key;
  }

  _unregister(T data) {
    anchors.remove(data);
  }

  @override
  Widget build(BuildContext context) {
    final connections = _calculateConnections();
    print(connections.length);
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
        register: _register,
        unregister: _unregister,
        notify: () => setState(() {}),
      ),
    );
  }
}

typedef void AnchorRegister<T>(T data, GlobalKey key);

class _TapInterceptor<T> extends InheritedWidget {
  final ValueChanged<T> onPointerDown;
  final ValueChanged<Offset> onPointerUp;
  final VoidCallback onPointerCancel;
  final AnchorRegister<T> register;
  final ValueChanged<T> unregister;
  final VoidCallback notify;

  _TapInterceptor({
    Key key,
    @required Widget child,
    @required this.onPointerUp,
    @required this.onPointerDown,
    @required this.onPointerCancel,
    @required this.register,
    @required this.unregister,
    @required this.notify,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_TapInterceptor oldWidget) => false;
}

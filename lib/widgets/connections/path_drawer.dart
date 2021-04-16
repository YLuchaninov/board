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
  final connections = <Connection, AnchorConnection>{};
  final anchors = <T, Offset>{};
  Offset start = Offset.zero;
  Offset end = Offset.zero;
  AnchorData startData;
  bool requestToInit = true;

  @override
  void didChangeDependencies() {
    if (requestToInit &&
        widget.connections != null &&
        widget.connections.isNotEmpty) {
      requestToInit = false;
      _fillConnections();
    }
    super.didChangeDependencies();
  }

  @override
  didUpdateWidget(PathDrawer oldWidget) {
    setState(() {
      _fillConnections();
    });

    super.didUpdateWidget(oldWidget);
  }

  _fillConnections() {
    if (!mounted) return;

    final removed = connections.keys.where(
      (key) => !widget.connections.contains(key),
    );
    removed.forEach((key) => connections.remove(key));

    final box = context.findRenderObject() as RenderBox;
    widget.connections?.forEach((connection) {
      if (anchors[connection.start] != null &&
          anchors[connection.end] != null) {
        final start = box.globalToLocal(anchors[connection.start]);
        final end = box.globalToLocal(anchors[connection.end]);

        connections[connection] = AnchorConnection(start: start, end: end);
      }
    });
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

  registerAnchor(T data, Offset offset) {
    anchors[data] = offset;
    if (!mounted) return;

    final box = context.findRenderObject() as RenderBox;
    widget.connections?.forEach((connection) {
      if ((connection.start == data || connection.end == data) &&
          (anchors[connection.start] != null &&
              anchors[connection.end] != null)) {
        final start = box.globalToLocal(anchors[connection.start]);
        final end = box.globalToLocal(anchors[connection.end]);
        connections[connection] = AnchorConnection(start: start, end: end);
      }
    });

    Future.delayed(Duration.zero, () => setState(() {}));
  }

  unregisterAnchor(T data) {
    anchors.remove(data);
    print('remove');
//    _fillConnections();

    connections.clear();

    Future.delayed(Duration.zero, () => setState((){}));

    // Future.delayed(
    //   Duration.zero,
    //   () => setState(() {
    //     final removed = connections.keys.where(
    //           (key) => key.start == data || key.end == data,
    //     );
    //     removed.forEach((key) => connections.remove(key));
    //   }),
    // );
  }

  @override
  Widget build(BuildContext context) {
    print(connections.length);
    return CustomPaint(
      foregroundPainter: LinePainter(
        enable: widget.enable,
        start: start,
        end: end,
        connections: connections.values.toList(growable: false),
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
        scale: widget.scale,
      ),
    );
  }
}

typedef void AnchorRegister<T>(T data, Offset offset);

class _TapInterceptor<T> extends InheritedWidget {
  final PointerNotifier onPointerDown;
  final ValueChanged<Offset> onPointerUp;
  final VoidCallback onPointerCancel;
  final AnchorRegister<T> register;
  final ValueChanged<T> unregister;
  final double scale;

  _TapInterceptor({
    Key key,
    @required Widget child,
    @required this.onPointerUp,
    @required this.onPointerDown,
    @required this.onPointerCancel,
    @required this.register,
    @required this.unregister,
    @required this.scale,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_TapInterceptor oldWidget) => false;
}

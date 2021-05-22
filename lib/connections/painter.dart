import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/drag_position.dart';
import '../core/types.dart';
import 'paint.dart';
import 'tap_interceptor.dart';
import 'anchor_handler.dart';
import 'connection.dart';

class ConnectionPainter<T> extends StatefulWidget {
  static TapInterceptor<T>? of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TapInterceptor<T>>();

  final bool enabled;
  final ValueNotifier<bool> drawSate;
  final double scale;
  final int itemCount;
  final IndexedPositionBuilder positionBuilder;
  final ValueNotifier<DragPosition> dragNotifier;
  final Widget child;
  final List<Connection<T>>? connections;
  final OnConnectionCreate<T>? onConnectionCreate;

  const ConnectionPainter({
    Key? key,
    required this.enabled,
    required this.child,
    required this.dragNotifier,
    required this.itemCount,
    required this.positionBuilder,
    required this.drawSate,
    required this.scale,
    required this.connections,
    required this.onConnectionCreate,
  }) : super(key: key);

  @override
  _ConnectionPainterState<T> createState() => _ConnectionPainterState<T>();
}

class _ConnectionPainterState<T> extends State<ConnectionPainter<T>> {
  final anchors = <T, GlobalKey>{};
  Offset? start = Offset.zero;
  Offset? end = Offset.zero;
  T? startData;
  bool requested = false;

  _requestToUpdate() {
    if (!requested) {
      requested = true;
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => setState(() => requested = false),
      );
    }
  }

  @override
  initState() {
    widget.dragNotifier.addListener(_onDragging);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConnectionPainter<T> oldWidget) {
    oldWidget.dragNotifier.removeListener(_onDragging);
    widget.dragNotifier.addListener(_onDragging);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.dragNotifier.removeListener(_onDragging);
    super.dispose();
  }

  _onDragging() => setState(() {});

  Offset _calculateAnchor(GlobalKey? key, RenderBox root) {
    final anchor = key?.currentContext?.findRenderObject() as RenderBox;
    final local =
        ((key?.currentWidget as MetaData).metaData as AnchorData).anchorOffset;
    final global = anchor.localToGlobal(local);

    return root.globalToLocal(global);
  }

  _onPointerDown(T data) {
    if (!widget.enabled) return;

    widget.drawSate.value = true;

    final box = context.findRenderObject();
    end = start = _calculateAnchor(anchors[data], box as RenderBox);
    startData = data;

    setState(() {});
  }

  _positionListener(PointerMoveEvent event) {
    if (widget.drawSate.value && widget.enabled) {
      setState(() {
        end = event.localPosition;
      });
    }
  }

  _onPointerCancel() {
    widget.drawSate.value = false;
    setState(() {
      end = start = Offset.zero;
      startData = null;
    });
  }

  _onPointerUp({
    Offset? globalTap,
    AnchorData? data,
    Size? size,
    Offset? position,
  }) {
    if (!widget.enabled) return;

    widget.drawSate.value = false;
    widget.onConnectionCreate?.call(startData!, data!.data);

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

      try {
        final entry = hitTestResult.path.toList().firstWhere((entry) {
          final target = entry.target;
          if (target is RenderMetaData) {
            final metaData = target.metaData;
            if (metaData is AnchorData) return true;
          }
          return false;
        });

        final target = entry.target;
        final metaData = (target as RenderMetaData).metaData;

        _onPointerUp(
          data: metaData,
          position: target.localToGlobal(Offset.zero),
          size: target.size,
          globalTap: tapOffset,
        );
      } catch (e) {
        _onPointerCancel();
      }
    }
  }

  _register(T data, GlobalKey key) {
    anchors[data] = key;
    _requestToUpdate();
  }

  _unregister(T data) {
    anchors.remove(data);
    _requestToUpdate();
  }

  List<AnchorConnection> _calculateConnections() {
    final connections = <AnchorConnection>[];
    final box = context.findRenderObject();
    if (box is RenderBox) {
      widget.connections?.forEach((connection) {
        if (anchors[connection.start] != null &&
            anchors[connection.end] != null) {
          connections.add(AnchorConnection(
            start: _calculateAnchor(anchors[connection.start], box),
            end: _calculateAnchor(anchors[connection.end], box),
          ));
        }
      });
    }

    return connections;
  }

  @override
  Widget build(BuildContext context) {
    final connections = _calculateConnections();

    return CustomPaint(
      foregroundPainter: PositionPainter(
        enable: widget.enabled,
        start: start,
        end: end,
        connections: connections,
      ),
      child: TapInterceptor<T>(
        child: Listener(
          onPointerMove: _positionListener,
          child: widget.child,
        ),
        onPointerDown: _onPointerDown,
        onPointerUp: _extractAnchorData,
        onPointerCancel: _onPointerCancel,
        register: _register,
        unregister: _unregister,
      ),
    );
  }
}

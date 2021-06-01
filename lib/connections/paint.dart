import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../core/drag_position.dart';
import '../core/types.dart';
import 'painter.dart';
import 'tap_interceptor.dart';
import 'anchor_handler.dart';
import 'connection.dart';
import 'paints/curve_paint.dart';
import 'selector.dart';

class ConnectionPainter<T> extends StatefulWidget {
  static TapInterceptor<T>? of<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TapInterceptor<T>>();

  final bool enabled;
  final ValueNotifier<bool> drawSate;
  final double scale;
  final int itemCount;
  final IndexedPositionBuilder positionBuilder;
  final ValueNotifier<DragPosition<T>> dragNotifier;
  final Widget child;
  final List<Connection<T>>? connections;
  final OnConnectionCreate<T>? onConnectionCreate;
  final GlobalKey viewPortKey;
  final TransformationController transformationController;
  final ValueChanged<Connection<T>?>? onConnectionTap;
  final bool showTapZones;

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
    required this.viewPortKey,
    required this.transformationController,
    required this.showTapZones,
    this.onConnectionTap,
  }) : super(key: key);

  @override
  _ConnectionPainterState<T> createState() => _ConnectionPainterState<T>();
}

class _ConnectionPainterState<T> extends State<ConnectionPainter<T>> {
  final anchors = <T, Offset>{}; // Offset is local position
  final alignments = <T, Alignment?>{};
  Offset? start = Offset.zero;
  Offset? end = Offset.zero;
  T? startData;

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
    anchors.clear();
    alignments.clear();
    widget.dragNotifier.removeListener(_onDragging);
    super.dispose();
  }

  _onDragging() => setState(() {
        final box = context.findRenderObject() as RenderBox;
        widget.dragNotifier.value.anchors.forEach((key, value) {
          anchors[key] = box.globalToLocal(value);
        });
      });

  _onPointerDown(T data) {
    if (!widget.enabled) return;

    widget.drawSate.value = true;
    end = start = anchors[data]!;
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

  _setAlignment(T data, Alignment? alignment) => alignments[data] = alignment;

  _unsetAlignment(T data) => alignments.remove(data);

  List<AnchorConnection<T>> _calculateConnections() {
    final connections = <AnchorConnection<T>>[];
    widget.connections?.forEach((connection) {
      if (anchors[connection.start] != null && anchors[connection.end] != null)
        connections.add(AnchorConnection<T>(
          connection: connection,
          start: anchors[connection.start]!,
          end: anchors[connection.end]!,
          startAlignment: alignments[connection.start],
          endAlignment: alignments[connection.end],
        ));
    });

    return connections;
  }

  @override
  Widget build(BuildContext context) {
    final connections = _calculateConnections();

    return CustomPaint(
      foregroundPainter: PositionPainter<T>(
        enable: widget.enabled,
        start: start,
        end: end,
        connections: connections,
        connectionPainter:
            CurvePainter(), // todo make possible to change Painter for different connections
      ),
      child: TapInterceptor<T>(
        child: Listener(
          onPointerMove: _positionListener,
          child: PaintSelector<T>(
            onTap: (Connection<T>? connection) =>
                widget.onConnectionTap?.call(connection),
            painter: CurvePainter(),
            // todo make possible to change Painter for different connections
            viewPortKey: widget.viewPortKey,
            connections: connections,
            child: widget.child,
            transformationController: widget.transformationController,
            showTapZones: widget.showTapZones,
          ),
        ),
        onPointerDown: _onPointerDown,
        onPointerUp: _extractAnchorData,
        onPointerCancel: _onPointerCancel,
        setAlignment: _setAlignment,
        unsetAlignment: _unsetAlignment,
      ),
    );
  }
}

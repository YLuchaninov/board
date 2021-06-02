import 'package:flutter/material.dart';

import '../connections/paint.dart';
import '../canvas/canvas.dart';
import '../core/types.dart';
import 'drag_position.dart';
import '../connections/connection.dart';

class Board<H extends Object, T> extends StatefulWidget {
  final bool enabled;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final IndexedPositionBuilder positionBuilder;
  final OnPositionChange onPositionChange;
  final double minScale;
  final double maxScale;
  final double height;
  final double width;
  final double? scale;
  final ValueChanged<double>? onScaleChange;
  final bool showGrid;
  final double cellWidth;
  final double cellHeight;
  final Color? gridColor;
  final double strokeWidth;
  final double dotLength;
  final OnAddFromSource<H>? onAddFromSource;
  final ValueChanged<int?>? onSelectChange;
  final IndexedMenuBuilder? menuBuilder;
  final bool longPressMenu;
  final CustomPainter? gridPainter;
  final AnchorSetter? anchorSetter;
  final VoidCallback? onBoardTap;
  final List<Connection<T>>? connections;
  final OnConnectionCreate<T>? onConnectionCreate;
  final ValueChanged<Connection<T>?>? onConnectionTap;
  final bool showTapZones;
  final EdgeInsets contentPadding;
  final PainterBuilder<T>? painterBuilder;

  const Board({
    Key? key,
    this.enabled = true,
    required this.itemBuilder,
    required this.itemCount,
    required this.positionBuilder,
    required this.onPositionChange,
    required this.height,
    required this.width,
    this.contentPadding = const EdgeInsets.all(0),
    this.scale,
    this.maxScale = 3.0,
    this.minScale = 0.5,
    this.onScaleChange,
    this.cellWidth = 50,
    this.cellHeight = 50,
    this.showGrid = true,
    this.gridColor,
    this.strokeWidth = 0.3,
    this.dotLength = 10,
    this.onAddFromSource,
    this.onSelectChange,
    this.longPressMenu = false,
    this.menuBuilder,
    this.gridPainter,
    this.anchorSetter,
    this.onBoardTap,
    this.connections,
    this.onConnectionCreate,
    this.onConnectionTap,
    this.showTapZones = false,
    this.painterBuilder,
  }) : super(key: key);

  @override
  _BoardState<H, T> createState() => _BoardState<H, T>();
}

class _BoardState<H extends Object, T> extends State<Board<H, T>> {
  final ValueNotifier<bool> drawSate = ValueNotifier<bool>(false);
  final ValueNotifier<DragPosition<T>> dragNotifier =
      ValueNotifier<DragPosition<T>>(DragPosition<T>(
    index: -1,
    offset: Offset.zero,
    anchors: {},
  ));
  final controller = TransformationController();
  final key = GlobalKey();
  double scale = 1;

  @override
  void initState() {
    drawSate.addListener(_onDrawStateChange);
    controller.addListener(_listener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Board<H, T> oldWidget) {
    if (widget.scale != null) {
      var _scale = widget.scale ?? controller.value.getMaxScaleOnAxis();
      if (_scale > widget.maxScale) _scale = widget.maxScale;
      if (_scale < widget.minScale) _scale = widget.minScale;

      if (_scale != controller.value.getMaxScaleOnAxis()) {
        final translation = controller.value.getTranslation();
        scale = _scale;
        controller.value = Matrix4.identity()
          // todo scale by viewport center
          ..translate(translation.x, translation.y)
          ..scale(scale, scale);
      }
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    drawSate.removeListener(_onDrawStateChange);
    controller.removeListener(_listener);
    controller.dispose();
    super.dispose();
  }

  _onDrawStateChange() => setState(() {});

  void _listener() {
    final newScale = controller.value.getMaxScaleOnAxis();
    if (scale != newScale)
      setState(() {
        scale = newScale;
        widget.onScaleChange?.call(scale);
      });

    // todo make scroll bar
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: InteractiveViewer(
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        transformationController: controller,
        scaleEnabled: !drawSate.value,
        constrained: false,
        panEnabled: !drawSate.value,
        boundaryMargin: widget.contentPadding,
        child: ConnectionPainter<T>(
          enabled: widget.enabled,
          itemCount: widget.itemCount,
          positionBuilder: widget.positionBuilder,
          dragNotifier: dragNotifier,
          connections: widget.connections,
          onConnectionCreate: widget.onConnectionCreate,
          scale: scale,
          viewPortKey: key,
          drawSate: drawSate,
          transformationController: controller,
          onConnectionTap: widget.onConnectionTap,
          showTapZones: widget.showTapZones,
          painterBuilder: widget.painterBuilder,
          child: BoardCanvas<H, T>(
            enabled: widget.enabled,
            viewPortKey: key,
            width: widget.width,
            height: widget.height,
            itemCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
            positionBuilder: widget.positionBuilder,
            onDragging: (index, offset, anchors) =>
                dragNotifier.value = DragPosition(
              index: index,
              offset: offset,
              anchors: anchors,
            ),
            onPositionChange: widget.onPositionChange,
            showGrid: widget.showGrid,
            cellWidth: widget.cellWidth,
            cellHeight: widget.cellHeight,
            scale: scale,
            color: widget.gridColor,
            strokeWidth: widget.strokeWidth,
            dotLength: widget.dotLength,
            onAddFromSource: widget.onAddFromSource,
            onSelectChange: widget.onSelectChange,
            longPressMenu: widget.longPressMenu,
            menuBuilder: widget.menuBuilder,
            gridPainter: widget.gridPainter,
            anchorSetter: widget.anchorSetter,
            onBoardTap: widget.onBoardTap,
            drawSate: drawSate,
          ),
        ),
      ),
    );
  }
}

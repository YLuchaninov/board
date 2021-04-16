import 'package:flutter/material.dart';

import 'grid/grid.dart';
import 'connections/path_drawer.dart';
import 'connections/connection.dart';

typedef void OnPositionChange(int index, Offset offset);
typedef void OnAddFromSource<H>(H handler, Offset dropPosition);
typedef Widget IndexedMenuBuilder(
  BuildContext context,
  int index,
  VoidCallback close,
);
typedef Offset AnchorSetter(Offset position);
typedef OnConnectionCreate<T>(T startData, T endData);

class Board<H, T> extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final bool longPressMenu;
  final IndexedMenuBuilder menuBuilder;
  final double height;
  final double width;
  final double minScale;
  final double maxScale;
  final double scale;
  final ValueChanged<double> onScaleChange;
  final OnAddFromSource<H> onAddFromSource;
  final OnPositionChange onPositionChange;
  final Map<int, Offset> positions;
  final bool enable;
  final VoidCallback onBoardTap;
  final ValueChanged<int> onSelectChange;
  final AnchorSetter anchorSetter;
  final CustomPainter gridPainter;
  final bool showGrid;
  final double cellWidth;
  final double cellHeight;
  final Color color;
  final double dotLength;
  final double strokeWidth;
  final List<Connection<T>> connections;
  final OnConnectionCreate<T> onConnectionCreate;

  const Board({
    Key key,
    this.enable = true,
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.positions,
    @required this.height,
    @required this.width,
    this.longPressMenu = false,
    this.menuBuilder,
    this.scale = 1,
    this.minScale = 0.5,
    this.maxScale = 2.5,
    this.onScaleChange,
    this.onPositionChange,
    this.onSelectChange,
    this.onAddFromSource,
    this.onBoardTap,
    this.anchorSetter,
    this.gridPainter,
    this.showGrid = true,
    this.color = Colors.black54,
    this.cellWidth = 30,
    this.cellHeight = 30,
    this.dotLength = 10,
    this.strokeWidth = 0.3,
    this.connections,
    this.onConnectionCreate,
  })  : assert(positions != null),
        super(key: key);

  @override
  _BoardState<H, T> createState() => _BoardState<H, T>();
}

class _BoardState<H, T> extends State<Board<H, T>> {
  final ValueNotifier<bool> drawSate = ValueNotifier<bool>(false);
  TransformationController controller;
  double scale = 1;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    drawSate.addListener(_onDrawStateChange);
    controller = TransformationController();
    controller.addListener(_listener);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Board oldWidget) {
    var _scale = widget.scale;
    if (_scale > widget.maxScale) _scale = widget.maxScale;
    if (_scale < widget.minScale) _scale = widget.minScale;

    if (_scale != controller.value.getMaxScaleOnAxis()) {
      scale = _scale;
      final translation = controller.value.getTranslation();
      controller.value = Matrix4.identity()
        ..translate(translation.x, translation.y)
        ..scale(scale, scale);
    }
    setState(() {});

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    drawSate.removeListener(_onDrawStateChange);
    controller.removeListener(_listener);
    controller.dispose();
    controller = null;
    super.dispose();
  }

  _onDrawStateChange() => setState(() {});

  void _listener() {
    final newScale = controller.value.getMaxScaleOnAxis();
    if (scale != newScale) {
      setState(() {
        scale = newScale;
        widget.onScaleChange?.call(scale);
      });
    }

    // todo make scroll bar
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: InteractiveViewer(
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        scaleEnabled: !drawSate.value,
        constrained: false,
        transformationController: controller,
        panEnabled: !drawSate.value,
        child: PathDrawer<T>(
          enable: widget.enable,
          drawSate: drawSate,
          scale: scale,
          connections: widget.connections,
          onConnectionCreate: widget.onConnectionCreate,
          child: GridWidget<H>(
            viewPortKey: key,
            width: widget.width,
            height: widget.height,
            itemBuilder: widget.itemBuilder,
            itemCount: widget.itemCount,
            scale: scale,
            onPositionChange: widget.onPositionChange,
            onAddFromSource: widget.onAddFromSource,
            positions: widget.positions,
            enable: widget.enable && !drawSate.value,
            onBoardTap: widget.onBoardTap,
            menuBuilder: widget.menuBuilder,
            longPressMenu: widget.longPressMenu,
            onSelectChange: widget.onSelectChange,
            gridPainter: widget.gridPainter,
            showGrid: widget.showGrid,
            cellWidth: widget.cellWidth,
            cellHeight: widget.cellHeight,
            color: widget.color,
            dotLength: widget.dotLength,
            strokeWidth: widget.strokeWidth,
            anchorSetter: widget.anchorSetter,
          ),
        ),
      ),
    );
  }
}

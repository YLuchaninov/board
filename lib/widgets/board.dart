import 'package:flutter/material.dart';

import 'grid/grid.dart';
import 'grid/handler.dart';

typedef void OnPositionChange(int index, Offset offset);
typedef void OnAddFromSource(Handler handler, Offset dropPosition);

class Board extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final IndexedWidgetBuilder menuBuilder;
  final double height;
  final double width;
  final Color lineColor;
  final bool isGridVisible;
  final double cellWidth;
  final double cellHeight;
  final bool snapToGrid;
  final double minScale;
  final double maxScale;
  final double scale;
  final ValueSetter<double> onScaleChange;
  final OnAddFromSource onAddFromSource;
  final OnPositionChange onPositionChange;
  final Map<int, Offset> positions;
  final bool enable;
  final ValueChanged<int> onItemTap;
  final VoidCallback onBoardTap;

  const Board({
    Key key,
    this.menuBuilder,
    @required this.itemBuilder,
    @required this.itemCount,
    @required this.positions,
    @required this.height,
    @required this.width,
    this.lineColor = Colors.black54,
    this.isGridVisible = true,
    this.snapToGrid = true,
    this.cellHeight = 30,
    this.cellWidth = 30,
    this.minScale = 0.5,
    this.maxScale = 2.5,
    this.scale = 1,
    this.onScaleChange,
    this.onPositionChange,
    this.onAddFromSource,
    this.enable = true,
    this.onBoardTap,
    this.onItemTap,
  })  : assert(positions != null),
        super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  TransformationController controller;
  double scale = 1;
  final ValueNotifier<bool> isPointerDown = ValueNotifier<bool>(false);
  final ValueNotifier<Offset> pointerOffset =
      ValueNotifier<Offset>(Offset.zero);
  final ValueNotifier<bool> drawState = ValueNotifier<bool>(false);

  @override
  void initState() {
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
    controller.removeListener(_listener);
    controller.dispose();
    controller = null;
    super.dispose();
  }

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
    return LayoutBuilder(
      builder: (_, constraints) {
        return IgnorePointer(
          ignoring: drawState.value,
          child: InteractiveViewer(
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            scaleEnabled: true,
            constrained: false,
            transformationController: controller,
            panEnabled: true,
            child: GridWidget(
              isVisible: widget.isGridVisible,
              width: widget.width,
              height: widget.height,
              color: widget.lineColor,
              itemBuilder: widget.itemBuilder,
              itemCount: widget.itemCount,
              cellHeight: widget.cellHeight,
              cellWidth: widget.cellWidth,
              snapToGrid: widget.snapToGrid,
              scale: scale,
              onPositionChange: widget.onPositionChange,
              onAddFromSource: widget.onAddFromSource,
              positions: widget.positions,
              enable: widget.enable,
              rootController: controller,
              size: Size(constraints.maxWidth, constraints.maxHeight),
              onBoardTap: widget.onBoardTap,
              onItemTap: widget.onItemTap,
              menuBuilder: widget.menuBuilder,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'grid/grid.dart';
import 'grid/handler.dart';

typedef void OnPositionChange(int index, Offset offset);
typedef void OnAddFromSource(Handler handler, Offset dropPosition);
typedef Widget IndexedMenuBuilder(
  BuildContext context,
  int index,
  VoidCallback close,
);
typedef Offset AnchorSetter(Offset position);

class Board extends StatefulWidget {
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
  final OnAddFromSource onAddFromSource;
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

  var pointerDown = false;

  _onPointerDown(event) {
    setState(() {
      pointerDown = true;
    });
  }

  _onPointerUp(event) {
    setState(() {
      pointerDown = false;
    });
  }

  _onPointerMove(PointerMoveEvent event) {
    //if (pointerDown) print(event.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerMove: _onPointerMove,
          child: InteractiveViewer(
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            scaleEnabled: true, // todo
            constrained: false,
            transformationController: controller,
            panEnabled: true, // todo
            child: GridWidget(
              width: widget.width,
              height: widget.height,
              itemBuilder: widget.itemBuilder,
              itemCount: widget.itemCount,
              scale: scale,
              onPositionChange: widget.onPositionChange,
              onAddFromSource: widget.onAddFromSource,
              positions: widget.positions,
              enable: widget.enable,
              rootController: controller,
              size: Size(constraints.maxWidth, constraints.maxHeight),
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
        );
      },
    );
  }
}

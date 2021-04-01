import 'package:flutter/material.dart';

import 'grid_painter.dart';
import 'handler.dart';
import '../item/item.dart';
import '../../board.dart';

class GridWidget extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Map<int, Offset> positions;
  final bool isVisible;
  final double height;
  final double width;
  final double cellWidth;
  final double cellHeight;
  final Color color;
  final bool snapToGrid;
  final double scale;
  final OnPositionChange onPositionChange;
  final bool enable;
  final Size size;
  final TransformationController rootController;
  final OnAddFromSource onAddFromSource;
  final VoidCallback onBoardTap;
  final IndexedWidgetBuilder menuBuilder;
  final bool longPressMenu;
  final ValueChanged<int> onSelectChange;

  const GridWidget({
    Key key,
    this.itemCount,
    this.itemBuilder,
    this.positions,
    this.width,
    this.height,
    this.isVisible,
    this.cellWidth,
    this.cellHeight,
    this.color,
    this.snapToGrid,
    this.scale,
    this.onPositionChange,
    this.onAddFromSource,
    this.enable,
    this.size,
    this.rootController,
    this.onBoardTap,
    this.menuBuilder,
    this.longPressMenu,
    this.onSelectChange,
  }) : super(key: key);

  @override
  _GridWidgetState createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  var _key = GlobalKey();
  var _handlers = <Key, ItemHandler>{};
  int selected;
  var menuOpened = false;

  @override
  initState() {
    _fillPositions();
    super.initState();
  }

  @override
  void didUpdateWidget(GridWidget oldWidget) {
    _fillPositions();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _handlers.clear();
    super.dispose();
  }

  void _fillPositions() {
    final newHandlers = <Key, ItemHandler>{};
    for (int i = 0; i < widget.itemCount; i++) {
      final child = widget.itemBuilder(context, i);
      final key = child.key;

      assert(key != null, 'Board child widget should contain a Key');

      newHandlers[key] = ItemHandler(
        index: i,
        globalKey: _handlers[key]?.globalKey ?? GlobalKey<BoardItemState>(),
      );
    }

    _handlers.clear();
    _handlers = newHandlers;
  }

  List<Widget> _wrapChildren(BuildContext context) {
    final result = <Widget>[];
    for (int i = 0; i < widget.itemCount; i++) {
      final child = widget.itemBuilder(context, i);
      assert(child is PreferredSizeWidget);

      final handler = _handlers[child.key];

      double x, y;
      if (widget.positions[i] != null) {
        x = widget.positions[i].dx;
        y = widget.positions[i].dy;
      } else {
        // place child without position into the center of viewport
        final viewPortSize = widget.size / widget.scale;
        final translation = widget.rootController.value.getTranslation();
        x = viewPortSize.width / 2 - translation.x / widget.scale;
        y = viewPortSize.height / 2 - translation.y / widget.scale;

        // center widget
        final size = (child as PreferredSizeWidget).preferredSize;
        x -= size.width.isFinite ? size.width / 2 : 0;
        y -= size.height.isFinite ? size.height / 2 : 0;

        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onPositionChange?.call(i, Offset(x, y)),
        );
      }

      result.add(Positioned(
        top: y,
        left: x,
        child: IgnorePointer(
          ignoring: !widget.enable,
          child: BoardItem(
            key: handler.globalKey,
            scale: widget.scale,
            child: child,
            handler: handler,
            onTap: createOnItemTap(i),
            onLongPress: createOnItemLongPress(i),
          ),
        ),
      ));
    }

    if (selected != null && menuOpened) {
      result.add(buildMenu(context));
    }

    return result;
  }

  Widget buildMenu(BuildContext context) {
    final menu = widget.menuBuilder(context, selected);

    assert(menu is PreferredSizeWidget);

    final size = (menu as PreferredSizeWidget).preferredSize;
    final child = widget.itemBuilder(context, selected);
    final key = _handlers[child.key].globalKey;
    final offset = (key.currentState as BoardItemState).offset;
    final position = widget.positions[selected] + offset;

    // todo centred menu

    return Positioned(
      top: position.dy,
      left: position.dx,
      width: size.width,
      height: size.height,
      child: menu,
    );
  }

  VoidCallback createOnItemTap(int index) {
    return () {
      setState(() {
        selected = selected == index ? null : index;
        menuOpened = false;
      });
      widget.onSelectChange?.call(selected);
    };
  }

  VoidCallback createOnItemLongPress(int index) {
    return () {
      var requestFlag = false;
      menuOpened = widget.longPressMenu;
      if (selected != index) {
        requestFlag = true;
        selected = index;
        widget.onSelectChange?.call(selected);
      }

      if (requestFlag || menuOpened) {
        setState(() {});
      }
    };
  }

  onBoardTap(_) {
    if (menuOpened) {
      setState(() {
        menuOpened = false;
        selected = null;
      });
      widget.onSelectChange?.call(selected);
    } else if (selected != null) {
      setState(() => selected = null);
      widget.onSelectChange?.call(selected);
    } else {
      widget.onBoardTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onBoardTap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: GridPainter(
            isVisible: widget.isVisible,
            color: widget.color,
            cellHeight: widget.cellHeight,
            cellWidth: widget.cellWidth,
          ),
          child: DragTarget<Handler>(
            builder: (context, candidateItems, rejectedItems) {
              return Stack(
                key: _key,
                fit: StackFit.expand,
                children: _wrapChildren(context),
              );
            },
            onWillAccept: (data) => data != null,
            onAcceptWithDetails: (DragTargetDetails position) {
              // drop new item
              if (!(position.data is ItemHandler)) {
                final RenderBox renderObject =
                    _key.currentContext.findRenderObject();
                final localOffset = renderObject.globalToLocal(position.offset);
                // todo center widget

                widget.onAddFromSource?.call(position.data, localOffset);
                return true;
              }

              // drop exist item
              setState(() {
                final data = (position.data as ItemHandler);
                RenderBox renderObject = _key.currentContext.findRenderObject();
                final localOffset = renderObject.globalToLocal(position.offset);
                final offset =
                    (data.globalKey.currentState as BoardItemState).offset;
                final newPosition =
                    localOffset - offset * (widget.scale - 1) / widget.scale;

                widget.onPositionChange?.call(data.index, newPosition);
              });
              return true;
            },
          ),
        ),
      ),
    );
  }
}

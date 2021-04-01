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
  final ValueChanged<int> onItemTap;
  final IndexedWidgetBuilder menuBuilder;

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
    this.onItemTap,
    this.menuBuilder,
  }) : super(key: key);

  @override
  _GridWidgetState createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  var _key = GlobalKey();
  var _handlers = <Key, ItemHandler>{};
  var menuIndex = -1;

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
            onTap: () {
              if (menuIndex != -1) {
                closeMenu();
              } else {
                widget.onItemTap?.call(i);
              }
            },
            onLongPress: () {
              if (menuIndex == -1) {
                openMenu(i);
              } else {
                closeMenu();
              }
            },
          ),
        ),
      ));
    }

    if (menuIndex != -1) {
      result.add(buildMenu(context));
    }

    return result;
  }

  Widget buildMenu(BuildContext context) {
    final menu = widget.menuBuilder(context, menuIndex);

    assert(menu is PreferredSizeWidget);

    final size = (menu as PreferredSizeWidget).preferredSize;
    final child = widget.itemBuilder(context, menuIndex);
    final key = _handlers[child.key].globalKey;
    final offset = (key.currentState as BoardItemState).offset;
    final position = widget.positions[menuIndex] + offset;

    // todo centred menu

    return Positioned(
      top: position.dy,
      left: position.dx,
      width: size.width,
      height: size.height,
      child: menu,
    );
  }

  openMenu(int index) => setState(() => menuIndex = index);

  closeMenu() => setState(() => menuIndex = -1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (menuIndex != -1) {
          closeMenu();
        } else {
          widget.onBoardTap?.call();
        }
      },
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
            onWillAccept: (data) {
              if (data == null) return false;
              return true;
            },
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

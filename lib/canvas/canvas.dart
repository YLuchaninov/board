import 'package:flutter/material.dart';

import 'item.dart';
import 'empty_painter.dart';
import 'grid_painter.dart';
import 'handler.dart';
import '../core/types.dart';

class BoardCanvas<H extends Object, T> extends StatefulWidget {
  final bool enabled;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final IndexedPositionBuilder positionBuilder;
  final OnIndexedDragging<T> onDragging;
  final OnPositionChange? onPositionChange;
  final double width;
  final double height;
  final double scale;
  final Color? color;
  final double cellWidth;
  final double cellHeight;
  final double strokeWidth;
  final double dotLength;
  final bool showGrid;
  final GlobalKey viewPortKey;
  final CustomPainter? gridPainter;
  final VoidCallback? onBoardTap;
  final ValueChanged<int?>? onSelectChange;
  final OnAddFromSource<H>? onAddFromSource;
  final bool longPressMenu;
  final IndexedMenuBuilder? menuBuilder;
  final AnchorSetter? anchorSetter;
  final ValueNotifier<bool> drawSate;

  const BoardCanvas({
    Key? key,
    required this.enabled,
    required this.width,
    required this.height,
    required this.scale,
    required this.itemCount,
    required this.itemBuilder,
    required this.positionBuilder,
    required this.onDragging,
    required this.onPositionChange,
    required this.color,
    required this.cellWidth,
    required this.cellHeight,
    required this.dotLength,
    required this.strokeWidth,
    required this.showGrid,
    required this.viewPortKey,
    required this.drawSate,
    this.gridPainter,
    this.onBoardTap,
    this.onSelectChange,
    this.onAddFromSource,
    this.longPressMenu = false,
    this.menuBuilder,
    this.anchorSetter,
  }) : super(key: key);

  @override
  _BoardCanvasState<H, T> createState() => _BoardCanvasState<H, T>();
}

class _BoardCanvasState<H extends Object, T> extends State<BoardCanvas<H, T>> {
  // todo separate to several abstractions for refactoring
  int? selected;
  bool menuOpened = false;
  var _handlers = <Key?, ItemHandler>{};

  @override
  void dispose() {
    _handlers.clear();
    super.dispose();
  }

  _clearHandlers(List<Key?> keys) {
    _handlers.removeWhere((key, handler) {
      if (!keys.contains(key)) {
        if (_handlers[key]!.index == selected) {
          selected = null;
          menuOpened = false;
          WidgetsBinding.instance!.addPostFrameCallback(
            (_) => widget.onSelectChange?.call(selected),
          );
        }
        return true;
      }
      return false;
    });
    keys.clear();
  }

  _close() => setState(() => menuOpened = false);

  Widget _buildMenu(BuildContext context) {
    final menu = widget.menuBuilder?.call(context, selected!, _close);

    assert(menu is PreferredSizeWidget);

    final menuSize = (menu as PreferredSizeWidget).preferredSize;
    final handler = _handlers.values.firstWhere(
      (value) => value.index == selected,
    );
    final key = handler.globalKey;
    final offset = (key.currentState as BoardItemState).panOffset;
    var position = widget.positionBuilder(selected!)! + offset;

    // adjustment menu position
    final viewport = widget.viewPortKey.currentContext?.findRenderObject();
    if (viewport is RenderBox) {
      final viewportPosition = viewport.localToGlobal(Offset.zero);
      final viewportSize = viewport.size;

      // vertical adjustment
      if (position + Offset(0, menuSize.height) >
          viewportPosition + Offset(0, viewportSize.height)) {
        position -= Offset(0, menuSize.height);
      }

      // horizontal adjustment
      if (position + Offset(menuSize.width, 0) >
          viewportPosition + Offset(viewportSize.width, 0)) {
        position -= Offset(menuSize.width, 0);
      }
    }

    return Positioned(
      top: position.dy,
      left: position.dx,
      width: menuSize.width,
      height: menuSize.height,
      child: menu,
    );
  }

  _onBoardTap(_) {
    if (menuOpened) {
      setState(() {
        menuOpened = false;
        selected = null;
      });
      widget.onSelectChange?.call(null);
    } else if (selected != null) {
      setState(() => selected = null);
      widget.onSelectChange?.call(null);
    } else {
      widget.onBoardTap?.call();
    }
  }

  VoidCallback _createOnItemTap(int index) {
    return () {
      if (index != selected) {
        setState(() {
          selected = index;
          menuOpened = false;
        });
        widget.onSelectChange?.call(selected);
      }
    };
  }

  VoidCallback _createOnItemLongPress(int index) {
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

  List<Widget> _wrapChildren(BuildContext context) {
    final result = <Widget>[];
    final keys = <Key?>[];

    for (var i = 0; i < widget.itemCount; i++) {
      final child = widget.itemBuilder(context, i);

      assert(child.key != null, 'Board child should contain a Key.');
      assert(child is PreferredSizeWidget,
          'Board child should be a PreferredSizeWidget.');

      final handler = ItemHandler(
        index: i,
        globalKey:
            _handlers[child.key]?.globalKey ?? GlobalKey<BoardItemState>(),
      );
      _handlers[child.key] = handler;

      var offset = widget.positionBuilder(i);
      if (offset == null) {
        offset = _placeWidgetToCenter(i, child as PreferredSizeWidget);
      }

      result.add(BoardItem<T>(
        key: handler.globalKey,
        enabled: widget.enabled && !widget.drawSate.value,
        position: offset,
        onChange: (_offset) => widget.onPositionChange?.call(i, _offset),
        onDragging: (_offset, _anchors) {
          widget.onDragging(i, _offset, _anchors);

          // hide menu when drag selected item
          if(selected == i) {
            selected = null;
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              widget.onSelectChange?.call(null);
            });
          }
        },
        child: child,
        onTap: _createOnItemTap(i),
        onLongPress: _createOnItemLongPress(i),
        anchorSetter: widget.anchorSetter,
      ));
      keys.add(child.key);
    }

    _clearHandlers(keys);
    if (selected != null && menuOpened && widget.enabled) {
      result.add(_buildMenu(context));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onBoardTap,
      child: CustomPaint(
        painter: widget.showGrid
            ? widget.gridPainter ??
                GridPainter(
                  color: widget.color,
                  cellWidth: widget.cellWidth,
                  cellHeight: widget.cellHeight,
                  dotLength: widget.dotLength,
                  strokeWidth: widget.strokeWidth,
                )
            : EmptyPainter(),
        child: DragTarget<H>(
          builder: (context, candidateItems, rejectedItems) {
            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                fit: StackFit.expand,
                children: _wrapChildren(context),
              ),
            );
          },
          onWillAccept: (handler) => handler != null && handler is H,
          onAcceptWithDetails: (DragTargetDetails event) =>
              _dropNewItem(event.data, event.offset),
        ),
      ),
    );
  }

  _dropNewItem(H sourceData, Offset offset) {
    final renderObject = context.findRenderObject() as RenderBox;
    final _position = renderObject.globalToLocal(offset);
    // todo center widget in zooming case

    widget.onAddFromSource?.call(sourceData, _position);
    return true;
  }

  Offset _placeWidgetToCenter(int index, PreferredSizeWidget child) {
    final renderBox = context.findRenderObject();

    var _position = Offset.zero;
    if (renderBox is RenderBox) {
      final viewPortBox =
          widget.viewPortKey.currentContext!.findRenderObject() as RenderBox;
      var viewPortSize = viewPortBox.size;
      final viewPortLeftTop = viewPortBox.localToGlobal(Offset.zero);
      final viewPortRightBottom = viewPortBox
          .localToGlobal(Offset(viewPortSize.width, viewPortSize.height));
      _position = -renderBox.localToGlobal(Offset.zero);
      _position +=
          viewPortLeftTop + (viewPortRightBottom - viewPortLeftTop) / 2;

      // center widget
      final size = child.preferredSize;
      final childOffset = Offset(
        size.width.isFinite ? size.width / 2 : 0,
        size.height.isFinite ? size.height / 2 : 0,
      );

      _position = _position / widget.scale - childOffset;
    }

    WidgetsBinding.instance!.addPostFrameCallback(
      (_) => widget.onPositionChange?.call(index, _position),
    );
    return _position;
  }
}

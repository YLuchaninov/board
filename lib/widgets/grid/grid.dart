import 'package:flutter/material.dart';

import 'grid_painter.dart';
import 'handler.dart';
import 'empty_painter.dart';
import '../item/item.dart';
import '../../board.dart';

const _AnimationDuration = 120;

class GridWidget extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Map<int, Offset> positions;
  final double height;
  final double width;
  final bool showGrid;
  final double cellWidth;
  final double cellHeight;
  final Color color;
  final double dotLength;
  final double strokeWidth;
  final double scale;
  final OnPositionChange onPositionChange;
  final bool enable;
  final OnAddFromSource onAddFromSource;
  final VoidCallback onBoardTap;
  final IndexedMenuBuilder menuBuilder;
  final bool longPressMenu;
  final ValueChanged<int> onSelectChange;
  final CustomPainter gridPainter;
  final AnchorSetter anchorSetter;
  final GlobalKey viewPortKey;

  const GridWidget({
    Key key,
    this.itemCount,
    this.itemBuilder,
    this.positions,
    this.width,
    this.height,
    this.showGrid,
    this.cellWidth,
    this.cellHeight,
    this.color,
    this.dotLength,
    this.strokeWidth,
    this.scale,
    this.onPositionChange,
    this.onAddFromSource,
    this.enable,
    this.onBoardTap,
    this.menuBuilder,
    this.longPressMenu,
    this.onSelectChange,
    this.gridPainter,
    this.anchorSetter,
    this.viewPortKey,
  }) : super(key: key);

  @override
  _GridWidgetState createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget>
    with SingleTickerProviderStateMixin {
  var _handlers = <Key, ItemHandler>{};
  int selected;
  var menuOpened = false;
  AnimationController animationController;
  Animation<Offset> animation;
  ItemHandler animated;

  @override
  initState() {
    animationController = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: _AnimationDuration),
      vsync: this,
    );
    animationController.addListener(_onAnimation);
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
    animationController.removeListener(_onAnimation);
    animationController.dispose();
    _handlers.clear();
    super.dispose();
  }

  void _fillPositions() {
    final newHandlers = <Key, ItemHandler>{};
    for (int i = 0; i < widget.itemCount; i++) {
      final child = widget.itemBuilder(context, i);
      final key = child.key;

      assert(key != null, 'Board child widget should contain a Key');

      final handler = ItemHandler(
        index: i,
        globalKey: _handlers[key]?.globalKey ?? GlobalKey<BoardItemState>(),
      );
      newHandlers[key] = handler;

      if (_handlers[key] == null &&
          widget.anchorSetter != null &&
          widget.positions[i] != null) {
        _stickToGrid(handler, widget.positions[i]);
      }
    }

    // clear menuOpened & selected
    final removed = _handlers.keys.where((k) => !newHandlers.keys.contains(k));
    removed.forEach((key) {
      if (_handlers[key].index == selected) {
        selected = null;
        menuOpened = false;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onSelectChange?.call(selected),
        );
      }
    });

    _handlers.clear();
    _handlers = newHandlers;
  }

  List<Widget> _wrapChildren(BuildContext context) {
    final result = <Widget>[];
    for (int i = 0; i < widget.itemCount; i++) {
      final child = widget.itemBuilder(context, i);
      assert(child is PreferredSizeWidget);

      final handler = _handlers[child.key];
      var offset = widget.positions[i] ?? _placeWidgetToCenter(i, child);

      if (handler.globalKey == animated?.globalKey) {
        offset = animation.value;
      }

      result.add(Positioned(
        top: offset.dy,
        left: offset.dx,
        child: BoardItem(
          enable: widget.enable,
          key: handler.globalKey,
          scale: widget.scale,
          child: child,
          handler: handler,
          onTap: _createOnItemTap(i),
          onLongPress: _createOnItemLongPress(i),
        ),
      ));
    }

    if (selected != null && menuOpened) {
      result.add(_buildMenu(context));
    }

    return result;
  }

  _close() => setState(() => menuOpened = false);

  Widget _buildMenu(BuildContext context) {
    final menu = widget.menuBuilder(context, selected, _close);

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

  VoidCallback _createOnItemTap(int index) {
    return () {
      setState(() {
        selected = selected == index ? null : index;
        menuOpened = false;
      });
      widget.onSelectChange?.call(selected);
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

  _onBoardTap(_) {
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
      onTapDown: _onBoardTap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
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
          child: DragTarget<Handler>(
            builder: (context, candidateItems, rejectedItems) {
              return Stack(
                fit: StackFit.expand,
                children: _wrapChildren(context),
              );
            },
            onWillAccept: (handler) => handler != null,
            onAcceptWithDetails: (DragTargetDetails event) {
              if (event.data is ItemHandler) {
                _dropExistItem(event.data, event.offset);
              } else {
                _dropNewItem(event.data, event.offset);
              }
              return true;
            },
          ),
        ),
      ),
    );
  }

  _dropNewItem(Handler handler, Offset offset) {
    final RenderBox renderObject = context.findRenderObject();
    final _position = renderObject.globalToLocal(offset);
    // todo center widget

    widget.onAddFromSource?.call(handler, _position);
  }

  _dropExistItem(Handler handler, Offset offset) {
    setState(() {
      final data = (handler as ItemHandler);
      final renderObject = context.findRenderObject() as RenderBox;
      final _local = renderObject.globalToLocal(offset);
      final _offset = (data.globalKey.currentState as BoardItemState).offset;
      final _position = _local - _offset * (widget.scale - 1) / widget.scale;

      widget.onPositionChange?.call(data.index, _position);
      _stickToGrid(handler, _position);
    });
  }

  Offset _placeWidgetToCenter(int index, PreferredSizeWidget child) {
    final renderBox = context.findRenderObject() as RenderBox;
    var _position = -renderBox.localToGlobal(Offset.zero);

    // place child without position into the center of viewport
    final viewPortBox =
        widget.viewPortKey.currentContext.findRenderObject() as RenderBox;
    var viewPortSize = viewPortBox.size;
    final viewPortLeftTop = viewPortBox.localToGlobal(Offset.zero);
    final viewPortRightBottom = viewPortBox
        .localToGlobal(Offset(viewPortSize.width, viewPortSize.height));

    _position += viewPortLeftTop + (viewPortRightBottom - viewPortLeftTop) / 2;

    // center widget
    final size = child.preferredSize;
    final childOffset = Offset(
      size.width.isFinite ? size.width / 2 : 0,
      size.height.isFinite ? size.height / 2 : 0,
    );

    _position = _position/widget.scale - childOffset;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onPositionChange?.call(index, _position),
    );
    _stickToGrid(_handlers[child.key], _position);

    return _position;
  }

  _stickToGrid(ItemHandler handler, Offset from) {
    if (widget.anchorSetter == null) return;
    final to = widget.anchorSetter(from);
    animation =
        Tween<Offset>(begin: from, end: to).animate(animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      animated = handler;
      animationController.forward(from: 0).whenComplete(() {
        animated = null;
        animation = null;
        widget.onPositionChange?.call(handler.index, to);
      });
    });
  }

  _onAnimation() => setState(() {});
}

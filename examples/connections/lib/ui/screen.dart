import 'package:board/widgets/grid/handler.dart';
import 'package:flutter/material.dart';
import 'package:board/board.dart';
import 'package:uuid/uuid.dart';

import 'widgets/index.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const height = 8000.0;
  static const width = 8000.0;
  static const maxScale = 3.0;
  static const minScale = 0.8;

  final uuid = Uuid();
  final children = <_Handler>[];
  final positions = <int, Offset>{};
  double scale = 1;
  int selectedIndex;

  @override
  void dispose() {
    children.clear();
    positions.clear();
    super.dispose();
  }

  onAddFromSource(handler, offset) {
    setState(() {
      children.add(handler);
      positions[children.length - 1] = offset;
    });
  }

  onScaleChange(val) {
    setState(() {
      if (val > _HomeScreenState.maxScale) val = _HomeScreenState.maxScale;
      if (val < _HomeScreenState.minScale) val = _HomeScreenState.minScale;

      scale = val;
    });
  }

  Widget itemBuilder(context, index) {
    return Item(
      title: 'Rect',
      selected: selectedIndex == index,
      data: children[index],
      key: Key(children[index].key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BoardSource(
                  source: ToolButton(
                    title: 'Rect',
                    onPressed: () {
                      setState(() => children.add(_Handler(key: uuid.v1())));
                    },
                  ),
                  feedback: Transform.scale(
                    scale: scale,
                    child: Item(title: 'Rect', data: null),
                  ),
                  boardData: _Handler(key: uuid.v1()),
                ),
              ],
            ),
          ),
          Expanded(
            child: Board(
              itemBuilder: itemBuilder,
              itemCount: children.length,
              positions: positions,
              height: _HomeScreenState.height,
              width: _HomeScreenState.width,
              onAddFromSource: onAddFromSource,
              onPositionChange: (index, offset) => setState(() {
                positions[index] = offset;
              }),
              minScale: _HomeScreenState.minScale,
              maxScale: _HomeScreenState.maxScale,
              scale: scale,
              onScaleChange: onScaleChange,
              longPressMenu: false,
              onSelectChange: (index) => setState(() => selectedIndex = index),
              approveDraw: (start, end) => start != end,
            ),
          ),
        ],
      ),
    );
  }
}

class _Handler extends Handler {
  final String key;

  _Handler({
    @required this.key,
  });

  @override
  String toString() => key;

  @override
  bool operator ==(Object other) => other is _Handler && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

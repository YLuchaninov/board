import 'package:flutter/material.dart';
import 'package:board/board.dart';
import 'package:uuid/uuid.dart';

import 'widgets/index.dart';
import 'painter.dart';

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
  final children = <String>[];
  final positions = <int, Offset>{};
  double scale = 1;
  int selectedIndex;

  @override
  void dispose() {
    children.clear();
    positions.clear();
    super.dispose();
  }

  onAddFromSource(uid, offset) {
    setState(() {
      children.add(uid);
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
      key: Key(children[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 64,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BoardSource<String>(
                    source: ToolButton(
                      title: 'Rect',
                      onPressed: () {
                        setState(() => children.add(uuid.v1()));
                      },
                    ),
                    feedback: Transform.scale(
                      scale: scale,
                      child: Item(title: 'Rect'),
                    ),
                    boardData: uuid.v1(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Board<String, dynamic>(
                itemBuilder: itemBuilder,
                itemCount: children.length,
                positions: positions,
                height: _HomeScreenState.height,
                width: _HomeScreenState.width,
                onAddFromSource: onAddFromSource,
                onPositionChange: (index, offset) =>
                    setState(() => positions[index] = offset),
                minScale: _HomeScreenState.minScale,
                maxScale: _HomeScreenState.maxScale,
                scale: scale,
                onScaleChange: onScaleChange,
                longPressMenu: false,
                onSelectChange: (index) =>
                    setState(() => selectedIndex = index),
                anchorSetter: (offset) =>
                    Offset((offset.dx / 100).round() * 100.0, offset.dy),
                gridPainter: Painter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

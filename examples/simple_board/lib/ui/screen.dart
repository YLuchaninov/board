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
  bool enable = true;

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
    switch (children[index].type) {
      case 1:
        return Type1(
          title: 'Circle',
          selected: selectedIndex == index,
          key: Key(children[index].key), // required!
        );
      case 2:
        return Type2(
          title: 'Rect',
          selected: selectedIndex == index,
          key: Key(children[index].key), // required!
        );
      default:
        return InputNode(
          selected: selectedIndex == index,
          key: Key(children[index].key), // required!
          text: children[index].data as String ?? '',
          onTextChange: (text) {
            children[index].data = text;
          },
        );
    }
  }

  deleteItem(int index) {
    if (index == null) return;

    setState(() {
      for (int i = index; i < children.length - 1; i++) {
        positions[i] = positions[i + 1];
      }
      positions.remove(children.length - 1);
      children.removeAt(index);
      selectedIndex = null;
    });
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
                  BoardSource(
                    source: ToolButton(
                      title: 'Circle',
                      onPressed: () {
                        setState(() => children.add(_Handler(
                              type: 1,
                              key: uuid.v1(),
                            )));
                      },
                    ),
                    feedback: Transform.scale(
                      scale: scale,
                      child: Type1(title: 'Circle'),
                    ),
                    boardData: _Handler(
                      type: 1,
                      key: uuid.v1(),
                    ),
                  ),
                  BoardSource(
                    source: ToolButton(
                      title: 'Rect',
                      onPressed: () {
                        setState(() => children.add(_Handler(
                              type: 2,
                              key: uuid.v1(),
                            )));
                      },
                    ),
                    feedback: Transform.scale(
                      scale: scale,
                      child: Type2(title: 'Rect'),
                    ),
                    boardData: _Handler(
                      type: 2,
                      key: uuid.v1(),
                    ),
                  ),
                  ToolButton(
                    title: 'Text',
                    onPressed: () {
                      setState(() => children.add(_Handler(
                            type: 3,
                            key: uuid.v1(),
                          )));
                    },
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  ToolButton(
                    title: 'Delete',
                    onPressed: () => deleteItem(selectedIndex),
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  ToolButton(
                    title: enable ? 'Off' : 'On',
                    onPressed: () => setState(() => enable = !enable),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Board(
                enable: enable,
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
                longPressMenu: true,
                menuBuilder: (context, index, close) => MenuWidget(
                  onDelete: () => deleteItem(index),
                  onCopy: () {
                    close();
                    setState(() {
                      children.add(children[index].clone(uuid.v1()));
                    });
                  },
                ),
                onSelectChange: (index) => setState(() => selectedIndex = index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handler extends Handler {
  final int type;
  final String key;
  dynamic data;

  _Handler({
    @required this.type,
    @required this.key,
    this.data,
  });

  _Handler clone(String key) {
    return _Handler(
      type: type,
      key: key,
      data: data,
    );
  }
}

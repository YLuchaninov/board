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
  final children = <Handler>[];
  final positions = <int, Offset>{};
  final connections = <Connection<String>>[];
  double scale = 1;
  int selectedIndex;

  @override
  void initState() {
    // predefine children
    children.addAll([
      Handler(key: uuid.v1(), anchors: [uuid.v1(), uuid.v1()]),
      Handler(key: uuid.v1(), anchors: [uuid.v1(), uuid.v1()]),
      Handler(key: uuid.v1(), anchors: [uuid.v1(), uuid.v1()]),
    ]);
    positions[0] = Offset(50, 100);
    positions[1] = Offset(150, 80);
    positions[2] = Offset(80, 200);

    connections.addAll([
      Connection<String>(children[0].anchors[0], children[1].anchors[0]),
      Connection<String>(children[0].anchors[1], children[2].anchors[0]),
      Connection<String>(children[1].anchors[1], children[2].anchors[1]),
      Connection<String>(children[0].anchors[1], children[2].anchors[1]),
    ]);

    super.initState();
  }

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
      anchorData: children[index].anchors,
      key: Key(children[index].key),
    );
  }

  onConnectionCreate(String start, String end) {
    print('$start - $end');
    setState(() {
      connections.add(Connection<String>(start, end));
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
                  BoardSource<Handler>(
                    source: ToolButton(
                      title: 'Rect',
                      onPressed: () {
                        setState(() => children.add(Handler(
                              key: uuid.v1(),
                              anchors: [uuid.v1(), uuid.v1()],
                            )));
                      },
                    ),
                    feedback: Transform.scale(
                      scale: scale,
                      child: Item(title: 'Rect', anchorData:['','']),
                    ),
                    boardData: Handler(
                      key: uuid.v1(),
                      anchors: [uuid.v1(), uuid.v1()],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Board<Handler, String>(
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
                onSelectChange: (index) =>
                    setState(() => selectedIndex = index),
                connections: connections,
                onConnectionCreate: onConnectionCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Handler {
  final String key;
  final List<String> anchors;

  Handler({
    @required this.key,
    @required this.anchors,
  });

  @override
  String toString() => key;

  @override
  bool operator ==(Object other) => other is Handler && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

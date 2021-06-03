import 'package:board/connections/paints/curve_paint.dart';
import 'package:flutter/material.dart';
import 'package:board/board.dart';
import 'package:uuid/uuid.dart';

import 'painter.dart';
import 'widgets/index.dart';
import '../../index.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final uuid = Uuid();
  final handlers = <_Handler>[];
  final connections = <Connection<String>>[];
  final ValueNotifier<RulerPosition> scroller = ValueNotifier<RulerPosition>(
    RulerPosition(
      position: Offset.zero,
      scale: 1,
    ),
  );

  int? selected;
  Connection<String>? selectedConnection;

  int columnCount = 1;

  @override
  void initState() {
    handlers.addAll([
      _Handler(
        position: Offset(0, 100),
        key: uuid.v1(),
        data: [uuid.v1(), uuid.v1()],
      ),
      _Handler(
        position: Offset(COLUMN_WIDTH, 150),
        key: uuid.v1(),
        data: [uuid.v1(), uuid.v1()],
      ),
      _Handler(
        position: Offset(0, 250),
        key: uuid.v1(),
        data: [uuid.v1(), uuid.v1()],
      ),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extended Trello'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.account_circle_sharp),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolBar(
              children: [
                Divider(
                  height: 1,
                ),
                BoardSource(
                  boardData: _Handler(
                    position: null,
                    key: uuid.v1(),
                    data: [uuid.v1(), uuid.v1()],
                  ),
                  source: ToolButton(
                    tooltip: 'Add Card',
                    icon: Icons.add_box_outlined,
                    onPressed: () => setState(() => handlers.add(_Handler(
                          position: null,
                          key: uuid.v1(),
                          data: [uuid.v1(), uuid.v1()],
                        ))),
                  ),
                  feedback: CardItem(
                    title: 'New Card',
                    anchorData: [uuid.v1(), uuid.v1()],
                  ),
                ),
                Divider(
                  height: 4,
                ),
                ToolButton(
                  tooltip: 'Delete selected',
                  icon: Icons.delete_forever_sharp,
                  onPressed: (selected == null && selectedConnection == null)
                      ? null
                      : () => setState(() {
                            if (selected != null) {
                              final handler = handlers[selected!];
                              handlers.removeAt(selected!);
                              connections.removeWhere((connection) {
                                // remove all connections, which connected with selected item
                                return handler.data.contains(connection.end) ||
                                    handler.data.contains(connection.start);
                              });
                            }
                            if (selectedConnection != null) {
                              connections.remove(selectedConnection);
                              selectedConnection = null;
                            }
                          }),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Ruler(
                    scroller: scroller,
                    contentWith: columnCount * COLUMN_WIDTH,
                    child: Container(),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Board<_Handler, String>(
                            width: columnCount * COLUMN_WIDTH + 1,
                            height: 8000,
                            minScale: 1,
                            maxScale: 1,
                            scale: 1,
                            dragPadding: const EdgeInsets.only(
                                right: COLUMN_WIDTH, top: 6),
                            itemBuilder: (context, index) => CardItem(
                              title: 'Item: $index',
                              key: Key(handlers[index].key),
                              anchorData: handlers[index].data,
                              selected: selected == index,
                            ),
                            itemCount: handlers.length,
                            positionBuilder: (index) =>
                                handlers[index].position,
                            onPositionChange: (index, offset) => setState(
                              () => handlers[index] =
                                  handlers[index].update(offset),
                            ),
                            onAddFromSource: (handler, offset) => setState(
                              () => handlers.add(handler.update(offset)),
                            ),
                            anchorSetter: (offset) {
                              Offset _offset = Offset(
                                (offset.dx / COLUMN_WIDTH).round() *
                                    COLUMN_WIDTH,
                                offset.dy,
                              );
                              if (_offset.dx >= columnCount * COLUMN_WIDTH)
                                _offset -= Offset(COLUMN_WIDTH, 0);

                              return _offset;
                            },
                            gridPainter: Painter(
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.5),
                            ),
                            onSelectChange: (index) =>
                                setState(() => selected = index),
                            connections: connections,
                            onConnectionCreate: (String start, String end) {
                              if (start == end) return;

                              final theSameItem = handlers.where((item) =>
                                  (item.data[0] == start &&
                                      item.data[1] == end) ||
                                  (item.data[0] == end &&
                                      item.data[1] == start));
                              if (theSameItem.isNotEmpty) return;

                              setState(
                                () => connections
                                    .add(Connection<String>(start, end)),
                              );
                            },
                            onConnectionTap: (connection) => setState(() {
                              selectedConnection = connection;
                            }),
                            painterBuilder: (connection) => CurvePainter(
                              strokeWidth:
                                  selectedConnection == connection ? 4 : 2,
                              color: selectedConnection == connection
                                  ? Theme.of(context).accentColor
                                  : Colors.red,
                            ),
                            onScroll: (offset, scale) =>
                                scroller.value = RulerPosition(
                              position: -offset,
                              scale: scale,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          height: 3,
                          left: 0,
                          right: 0,
                          child: BoardBar(
                            scroller: scroller,
                            contentSize: columnCount * COLUMN_WIDTH,
                            direction: Axis.horizontal,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          width: 3,
                          top: 0,
                          bottom: 0,
                          child: BoardBar(
                            scroller: scroller,
                            contentSize: 8000,
                            direction: Axis.vertical,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handler {
  final Offset? position;
  final String key;
  final List<String> data;

  _Handler({
    required this.position,
    required this.key,
    required this.data,
  });

  update(Offset offset) {
    return _Handler(
      position: offset,
      key: key,
      data: data,
    );
  }

  @override
  String toString() => key;
}

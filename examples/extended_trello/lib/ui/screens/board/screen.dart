import 'package:board/connections/paints/curve_paint.dart';
import 'package:flutter/material.dart';
import 'package:board/board.dart';
import 'package:uuid/uuid.dart';

import 'painter.dart';
import 'widgets/index.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final uuid = Uuid();
  final handlers = <_Handler>[];
  final connections = <Connection<String>>[];

  bool gridEnabled = true;
  bool enabled = true;
  int? selected;
  Connection<String>? selectedConnection;

  @override
  void initState() {
    handlers.addAll([
      _Handler(
        position: Offset(0, 100),
        key: uuid.v1(),
        data: [uuid.v1(), uuid.v1()],
      ),
      _Handler(
        position: Offset(300, 150),
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
              child: Board<_Handler, String>(
                width: 8000,
                height: 8000,
                minScale: 1,
                maxScale: 1,
                scale: 1,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) => CardItem(
                  title: 'Item: $index',
                  key: Key(handlers[index].key),
                  anchorData: handlers[index].data,
                  selected: selected == index,
                ),
                itemCount: handlers.length,
                positionBuilder: (index) => handlers[index].position,
                onPositionChange: (index, offset) => setState(
                  () => handlers[index] = handlers[index].update(offset),
                ),
                showGrid: gridEnabled,
                enabled: enabled,
                onAddFromSource: (handler, offset) => setState(
                  () => handlers.add(handler.update(offset)),
                ),
                anchorSetter: (offset) =>
                    Offset((offset.dx / 300).round() * 300.0, offset.dy),
                gridPainter: Painter(
                  color: Theme.of(context).accentColor.withOpacity(0.5),
                ),
                onSelectChange: (index) => setState(() => selected = index),
                connections: connections,
                onConnectionCreate: (String start, String end) {
                  if (start == end) return;

                  final theSameItem = handlers.where((item) =>
                      (item.data[0] == start && item.data[1] == end) ||
                      (item.data[0] == end && item.data[1] == start));
                  if (theSameItem.isNotEmpty) return;

                  setState(
                    () => connections.add(Connection<String>(start, end)),
                  );
                },
                onConnectionTap: (connection) => setState(() {
                  selectedConnection = connection;
                }),
                painterBuilder: (connection) => CurvePainter(
                  strokeWidth: selectedConnection == connection ? 4 : 2,
                  color: selectedConnection == connection
                      ? Theme.of(context).accentColor
                      : Colors.red,
                ),
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

import 'package:flutter/material.dart';
import 'package:board/board.dart';
import 'package:uuid/uuid.dart';

import 'widgets/index.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uuid = Uuid();
  final handlers = <_Handler>[];
  final connections = <Connection<String>>[];

  bool gridEnabled = true;
  bool enabled = true;
  int? selected;

  @override
  void initState() {
    handlers.addAll([
      _Handler(
        position: Offset(50, 100),
        key: uuid.v1(),
        type: 1,
        data: [uuid.v1(), uuid.v1()],
      ),
      _Handler(
        position: Offset(150, 150),
        key: uuid.v1(),
        type: 2,
        data: [uuid.v1(), uuid.v1(), uuid.v1(), uuid.v1()],
      ),
      _Handler(
        position: Offset(50, 250),
        key: uuid.v1(),
        type: 1,
        data: [uuid.v1(), uuid.v1()],
      ),
    ]);

    connections.addAll([
      Connection<String>(handlers[0].data[0], handlers[1].data[3]),
      Connection<String>(handlers[0].data[1], handlers[2].data[0]),
      Connection<String>(handlers[1].data[0], handlers[2].data[1]),
    ]);

    super.initState();
  }

  Widget _createToolbar(BuildContext context) {
    return ToolBar(
      children: [
        BoardSource<_Handler>(
          boardData: _Handler(
            type: 1,
            position: null,
            key: uuid.v1(),
            data: [uuid.v1(), uuid.v1()],
          ),
          feedback: Type1(title: 'Item: ', anchorData: ['', '']),
          source: ToolButton(
            icon: Icons.add_box,
            onPressed: () => setState(() => handlers.add(_Handler(
                  type: 1,
                  position: null,
                  key: uuid.v1(),
                  data: [uuid.v1(), uuid.v1()],
                ))),
          ),
        ),
        BoardSource<_Handler>(
          boardData: _Handler(
            type: 2,
            position: null,
            key: uuid.v1(),
            data: [uuid.v1(), uuid.v1(), uuid.v1(), uuid.v1()],
          ),
          feedback: Type2(title: 'Item: ', anchorData: ['', '', '', '']),
          source: ToolButton(
            icon: Icons.add_box_outlined,
            onPressed: () => setState(() => handlers.add(_Handler(
                  type: 2,
                  position: null,
                  key: uuid.v1(),
                  data: [uuid.v1(), uuid.v1(), uuid.v1(), uuid.v1()],
                ))),
          ),
        ),
        SizedBox(
          height: 24,
        ),
        ToolButton(
          icon: Icons.delete_forever_sharp,
          onPressed: selected == null
              ? null
              : () => setState(() {
                    final handler = handlers[selected!];
                    handlers.removeAt(selected!);
                    connections.removeWhere((connection) {
                      // remove all connections, which connected with selected item
                      return handler.data.contains(connection.end) ||
                          handler.data.contains(connection.start);
                    });
                  }),
        ),
        ToolButton(
          icon: gridEnabled ? Icons.grid_off : Icons.grid_on,
          onPressed: () => setState(() => gridEnabled = !gridEnabled),
        ),
        ToolButton(
          icon: enabled ? Icons.near_me_disabled : Icons.near_me,
          onPressed: () => setState(() => enabled = !enabled),
        ),
      ],
    );
  }

  Widget _itemBuilder(context, index) {
    switch (handlers[index].type) {
      case 2:
        return Type2(
          selected: selected == index,
          title: 'Item: $index',
          key: Key(handlers[index].key),
          anchorData: handlers[index].data,
        );
      default:
        return Type1(
          selected: selected == index,
          title: 'Item: $index',
          key: Key(handlers[index].key),
          anchorData: handlers[index].data,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connections Demo')),
      body: SafeArea(
        child: Row(
          children: [
            _createToolbar(context),
            Expanded(
              child: Board<_Handler, String>(
                width: 8000,
                height: 8000,
                itemBuilder: _itemBuilder,
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
                onSelectChange: (index) => setState(() => selected = index),
                connections: connections,
                onConnectionCreate: (String start, String end) {
                  if (start != end)
                    setState(
                      () => connections.add(Connection<String>(start, end)),
                    );
                },
                onConnectionTap: (connection)=>print(connection),
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
  final int type;
  final List<String> data;

  _Handler({
    required this.position,
    required this.key,
    required this.type,
    required this.data,
  });

  update(Offset offset) {
    return _Handler(
      type: type,
      position: offset,
      key: key,
      data: data,
    );
  }

  @override
  String toString() => key;
}

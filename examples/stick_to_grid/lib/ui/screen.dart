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
  final uuid = Uuid();
  final handlers = <_Handler>[];

  bool gridEnabled = true;
  bool enabled = true;

  @override
  void initState() {
    handlers.addAll([
      _Handler(position: Offset(50, 100), key: uuid.v1()),
      _Handler(position: Offset(150, 150), key: uuid.v1()),
      _Handler(position: Offset(50, 250), key: uuid.v1()),
    ]);
    super.initState();
  }

  Widget _createToolbar(BuildContext context) {
    return ToolBar(
      children: [
        BoardSource<_Handler>(
          boardData: _Handler(
            position: null,
            key: uuid.v1(),
          ),
          feedback: Type1(title: 'Item: '),
          source: ToolButton(
            icon: Icons.add_box,
            onPressed: () => setState(() => handlers.add(_Handler(
                  position: null,
                  key: uuid.v1(),
                ))),
          ),
        ),
        SizedBox(
          height: 24,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stick to Grid Demo')),
      body: SafeArea(
        child: Row(
          children: [
            _createToolbar(context),
            Expanded(
              child: Board<_Handler, dynamic>(
                width: 8000,
                height: 8000,
                itemBuilder: (context, index) => Type1(
                  title: 'Item: $index',
                  key: Key(handlers[index].key),
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

class _Handler {
  final Offset? position;
  final String key;

  _Handler({
    required this.position,
    required this.key,
  });

  update(Offset offset) {
    return _Handler(
      position: offset,
      key: key,
    );
  }

  @override
  String toString() => key;
}

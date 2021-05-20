import 'package:flutter/material.dart';
import 'package:board/board.dart';
import 'package:uuid/uuid.dart';

import 'widgets/index.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double minScale = 0.5;
  static const double maxScale = 3;
  final uuid = Uuid();
  final handlers = <_Handler>[];

  bool gridEnabled = true;
  bool enabled = true;
  double scale = 1;
  int? selected;

  @override
  void initState() {
    handlers.addAll([
      _Handler(position: Offset(50, 100), type: 1, key: uuid.v1()),
      _Handler(position: Offset(150, 150), type: 2, key: uuid.v1()),
      _Handler(position: Offset(50, 250), type: 1, key: uuid.v1()),
    ]);
    super.initState();
  }

  Widget _createToolbar(BuildContext context) {
    return ToolBar(
      children: [
        BoardSource<_Handler>(
          scale: scale,
          boardData: _Handler(
            position: null,
            type: 1,
            key: uuid.v1(),
          ),
          feedback: Type1(title: 'Item: '),
          source: ToolButton(
            icon: Icons.add_box,
            onPressed: () => setState(() => handlers.add(_Handler(
                  position: null,
                  type: 1,
                  key: uuid.v1(),
                ))),
          ),
        ),
        BoardSource<_Handler>(
          scale: scale,
          boardData: _Handler(
            position: null,
            type: 2,
            key: uuid.v1(),
          ),
          feedback: Type2(title: 'Item: '),
          source: ToolButton(
            icon: Icons.add_circle_outline_rounded,
            onPressed: () => setState(() => handlers.add(_Handler(
                  position: null,
                  type: 2,
                  key: uuid.v1(),
                ))),
          ),
        ),
        ToolButton(
          icon: Icons.receipt,
          onPressed: () => setState(() => handlers.add(_Handler(
                position: null,
                type: 3,
                key: uuid.v1(),
              ))),
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
        VSlider(
          value: scale,
          onChanged: (_scale) => setState(() => scale = _scale),
          divisions: 10,
          min: _HomeScreenState.minScale,
          max: _HomeScreenState.maxScale,
        ),
      ],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    switch (handlers[index].type) {
      case (2):
        return Type2(
          selected: selected == index,
          title: 'Item: $index',
          key: Key(handlers[index].key),
        );
      case (3):
        return InputNode(
          key: Key(handlers[index].key),
          enabled: enabled,
          selected: selected == index,
          title: 'Item: $index',
          text: (handlers[index].data ?? '') as String,
          onTextChange: (value) => handlers[index].data = value,
        );
      default:
        return Type1(
          selected: selected == index,
          title: 'Item: $index',
          key: Key(handlers[index].key),
        );
    }
  }

  Widget _menuBuilder(context, index, close) {
    return MenuWidget(
      onCopy: () => setState(() {
        close();
        handlers.add(
          _Handler(
            position: null,
            type: handlers[index].type,
            key: uuid.v1(),
            data: handlers[index].data,
          ),
        );
      }),
      onDelete: () => setState(() {
        close();
        handlers.removeAt(index);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Board Demo')),
      body: SafeArea(
        child: Row(
          children: [
            _createToolbar(context),
            Expanded(
              child: Board<_Handler, dynamic>(
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
                scale: scale,
                minScale: _HomeScreenState.minScale,
                maxScale: _HomeScreenState.maxScale,
                onScaleChange: (_scale) => setState(() => scale = _scale),
                onAddFromSource: (handler, offset) => setState(
                  () => handlers.add(handler.update(offset)),
                ),
                onSelectChange: (index) => setState(() => selected = index),
                longPressMenu: true,
                menuBuilder: _menuBuilder,
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
  final int type;
  final String key;
  dynamic data;

  _Handler({
    required this.position,
    required this.type,
    required this.key,
    this.data,
  });

  update(Offset offset) {
    return _Handler(
      position: offset,
      type: type,
      key: key,
      data: data,
    );
  }

  @override
  String toString() => key;
}

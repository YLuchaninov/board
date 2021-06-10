import 'package:flutter/material.dart';
import 'package:board/board.dart';

import '../widgets/index.dart';
import '../../../../logic/index.dart';

Widget buildToolbar(BuildContext context, BLoC? bloc, bool selected) {
  return ToolBar(
    children: [
      Divider(
        height: 1,
      ),
      BoardSource<Object>(
        boardData: {},
        source: ToolButton(
          tooltip: 'Add Stage',
          icon: Icons.add_box_outlined,
          onPressed: () => bloc!.action.add(CreateStage()),
        ),
        feedback: CardItem(
          title: 'New Card',
          anchorData: ['', ''],
        ),
      ),
      Divider(
        height: 4,
      ),
      ToolButton(
        tooltip: 'Delete selected',
        icon: Icons.delete_forever_sharp,
        onPressed: selected ? null : _deleteSelection,
      ),
    ],
  );
}

void _deleteSelection() {
  // todo setState(() {
  //   if (selected != null) {
  //     final handler = handlers[selected!];
  //     handlers.removeAt(selected!);
  //     connections.removeWhere((connection) {
  //       // remove all connections, which connected with selected item
  //       return handler.data.contains(connection.end) ||
  //           handler.data.contains(connection.start);
  //     });
  //   }
  //   if (selectedConnection != null) {
  //     connections.remove(selectedConnection);
  //     selectedConnection = null;
  //   }
  // });
}

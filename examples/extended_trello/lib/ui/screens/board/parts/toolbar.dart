import 'package:flutter/material.dart';
import 'package:board/board.dart';

import '../widgets/index.dart';
import '../../../../logic/index.dart';

Widget buildToolbar({
  required BuildContext context,
  required BLoC? bloc,
  required bool selected,
  required VoidCallback onDelete,
}) {
  return ToolBar(
    children: [
      ToolButton(
        tooltip: 'Add Stage',
        icon: Icons.add_box_outlined,
        onPressed: () => bloc!.action.add(CreateStage()),
      ),
      Divider(
        height: 4,
      ),
      ToolButton(
        tooltip: 'Delete selected',
        icon: Icons.delete_forever_sharp,
        onPressed: selected ? null : onDelete,
      ),
    ],
  );
}

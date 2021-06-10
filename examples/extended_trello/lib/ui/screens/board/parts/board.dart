import 'package:flutter/material.dart';
import 'package:board/board.dart';

import '../../../../logic/index.dart';
import '../../../index.dart';
import '../widgets/index.dart';
import 'painter.dart';

Widget buildBoard({
  required BuildContext context,
  BLoC? bloc,
  required ValueNotifier<RulerPosition> scroller,
  required double boardHeight,
  required ValueChanged<Badge?> onSelectChange,
  required ValueChanged<Connection<String>?> onConnectionTap,
  required Connection<String>? selectedConnection,
  required Badge? selectedBadge,
}) {
  final theme = Theme.of(context);

  return StreamBuilder<Project>(
      stream: bloc!.project,
      builder: (context, snapshot) {
        if (snapshot.data == null) return Container();

        final project = snapshot.data;
        final columnCount = project!.stages.length;
        final badges = <Badge>[];
        project.stages.forEach((stage) {
          badges.addAll(stage.badges);
        });
        final connections = <Connection<String>>[];
        project.relations.forEach(
              (relation) =>
              connections.add(
                Connection<String>(
                  relation.startId,
                  relation.endId,
                ),
              ),
        );

        return Column(
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
                    child: Board<Object, String>(
                      width: columnCount * COLUMN_WIDTH + 1,
                      height: boardHeight,
                      minScale: 1,
                      maxScale: 1,
                      scale: 1,
                      dragPadding: const EdgeInsets.only(
                        right: COLUMN_WIDTH,
                        top: 6,
                      ),
                      itemBuilder: (context, index) =>
                          CardItem(
                            title: badges[index].task.title,
                            key: Key(badges[index].key),
                            anchorData: [
                              badges[index].inputId,
                              badges[index].outputId,
                            ],
                            selected: selectedBadge == badges[index],
                          ),
                      itemCount: badges.length,
                      positionBuilder: (index) => badges[index].position,
                      onPositionChange: (index, offset) {
                        badges[index].position = offset;
                        bloc.action.add(UpdateCard(badges[index]));
                      },
                      onAddFromSource: (_, offset) {
                        int index = (offset.dx / COLUMN_WIDTH).ceil();
                        if (index < 0) index = 0;
                        if (index > project.stages.length - 1)
                          index = project.stages.length - 1;

                        final stage = project.stages[index];
                        bloc.action.add(CreateCard(stage));
                      },
                      anchorSetter: (offset) {
                        Offset _offset = Offset(
                          (offset.dx / COLUMN_WIDTH).round() * COLUMN_WIDTH,
                          offset.dy,
                        );
                        if (_offset.dx >= columnCount * COLUMN_WIDTH)
                          _offset -= Offset(COLUMN_WIDTH, 0);

                        return _offset;
                      },
                      gridPainter: Painter(
                        color: theme.accentColor.withOpacity(0.5),
                      ),
                      onSelectChange: (index) =>
                          onSelectChange(index != null ? badges[index] : null),
                      connections: connections,
                      onConnectionCreate: _onConnectionCreate,
                      onConnectionTap: onConnectionTap,
                      painterBuilder: (connection) =>
                          CurvePainter(
                            strokeWidth: selectedConnection == connection
                                ? 4
                                : 2,
                            color: selectedConnection == connection
                                ? theme.accentColor
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
                      contentSize: boardHeight,
                      direction: Axis.vertical,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      });
}

void _onConnectionCreate(String start, String end) {
  // todo if (start == end) return;
  //
  // final theSameItem = handlers.where((item) =>
  //     (item.data[0] == start && item.data[1] == end) ||
  //     (item.data[0] == end && item.data[1] == start));
  // if (theSameItem.isNotEmpty) return;
  //
  // setState(
  //   () => connections.add(Connection<String>(start, end)),
  // );
}

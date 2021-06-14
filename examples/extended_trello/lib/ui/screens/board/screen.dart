import 'package:extended_trello/ui/screens/board/parts/board.dart';
import 'package:flutter/material.dart';
import 'package:board/board.dart';

import 'widgets/index.dart';
import 'parts/index.dart';
import '../../../logic/index.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final ValueNotifier<RulerPosition> scroller = ValueNotifier<RulerPosition>(
    RulerPosition(
      position: Offset.zero,
      scale: 1,
    ),
  );

  Badge? badge;
  Connection<String>? connection;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BLoC>(context);

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
            buildToolbar(
                context: context,
                bloc: bloc,
                selected: badge == null && connection == null,
                onDelete: () {
                  if (badge != null) {
                    bloc!.action.add(DeleteBadge(badge!));
                    badge = null;
                  }
                  if (connection != null) {
                    bloc!.action.add(RemoveRelation(Relation(
                      startId: connection!.start,
                      endId: connection!.end,
                    )));
                    connection = null;
                  }
                }),
            Expanded(
              child: buildBoard(
                context: context,
                bloc: bloc,
                onSelectChange: (value) => setState(() => badge = value),
                onConnectionTap: (value) => setState(() => connection = value),
                selectedConnection: connection,
                selectedBadge: badge,
                scroller: scroller,
                boardHeight: 8000,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

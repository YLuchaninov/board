import 'package:flutter/material.dart';
import 'package:board/board.dart';

import '../../../constants/index.dart';
import '../../../../logic/index.dart';
import '../widgets/index.dart';

class StageHeader extends StatelessWidget {
  final Stage stage;
  final BLoC? bloc;

  const StageHeader({
    Key? key,
    required this.stage,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: COLUMN_WIDTH,
      child: Container(
        margin: EdgeInsets.only(right: 1, bottom: 1),
        decoration: BoxDecoration(
          color: theme.cardColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text('${stage.title} (${stage.badges.length})'),
              ),
            ),
            SizedBox(
              width: 48,
              child: BoardSource<Object>(
                boardData: {},
                source: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Center(child: Icon(Icons.add_circle)),
                    onTap: () {
                      bloc!.action.add(CreateBadge(stage: stage, offset: null));
                    },
                  ),
                ),
                feedback: CardItem(
                  title: 'New Card',
                  anchorData: ['', ''],
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton(
                  offset: Offset(0, 62),
                  child: Icon(Icons.more_horiz),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Text('Edit Stage'),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text('Delete Stage'),
                    ),
                  ],
                  onSelected: (value) {
                    switch(value){
                      case 1:
                        bloc!.action.add(DeleteStage(stage));
                        break;
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

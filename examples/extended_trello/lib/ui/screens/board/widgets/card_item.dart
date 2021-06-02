import 'package:flutter/material.dart';
import 'package:board/board.dart';

import '../../../index.dart';

class CardItem extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final bool selected;
  final List<String> anchorData;

  const CardItem({
    Key? key,
    required this.title,
    this.selected = false,
    required this.anchorData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.loose,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: COLUMN_WIDTH,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? theme.accentColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(6)),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: theme.cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 8,
                    bottom: 8,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1, color: theme.accentColor),
                      ),
                      hintText: 'Enter a Text',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          left: 2,
          width: 20,
          top: 15,
          height: 20,
          child: DrawAnchor<String>(
            alignment: Alignment.centerLeft,
            anchorOffset: Offset(2, 25),
            data: anchorData[0],
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor,
              ),
            ),
          ),
        ),
        Positioned(
          right: 2,
          width: 20,
          top: 15,
          height: 20,
          child: DrawAnchor<String>(
            alignment: Alignment.centerRight,
            anchorOffset: Offset(COLUMN_WIDTH - 2, 25),
            data: anchorData[1],
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromWidth(COLUMN_WIDTH);
}

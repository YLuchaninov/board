import 'package:flutter/material.dart';
import 'package:board/board.dart';

class Item extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final bool selected;
  final AnchorData data;

  const Item({
    Key key,
    @required this.title,
    @required this.data,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 40,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 10,
            width: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                border: Border.all(
                  color: selected ? Colors.redAccent : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(title),
            ),
          ),
          Positioned(
            left: 0,
            top: 10,
            width: 20,
            height: 20,
            child: DrawAnchor(
              data: data,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 10,
            width: 20,
            height: 20,
            child: DrawAnchor(
              data: data,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size(100, 40);
}

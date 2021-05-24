import 'package:flutter/material.dart';
import 'package:board/board.dart';

class Type1 extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final bool selected;
  final List<String> anchorData;

  const Type1({
    Key? key,
    required this.title,
    required this.anchorData,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 120,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            height: 50,
            left: 10,
            width: 100,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? Colors.deepOrange : Colors.transparent,
                  width: 2,
                ),
                color: Colors.blueAccent,
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: 20,
            top: 15,
            height: 20,
            child: DrawAnchor<String>(
              anchorOffset: Offset(10, 25),
              data: anchorData[0],
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
            width: 20,
            top: 15,
            height: 20,
            child: DrawAnchor<String>(
              anchorOffset: Offset(110, 25),
              data: anchorData[1],
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
  Size get preferredSize => Size(120, 50);
}

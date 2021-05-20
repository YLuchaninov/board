import 'package:flutter/material.dart';

class Type2 extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final bool selected;

  const Type2({
    Key? key,
    required this.title,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      height: 75,
      width: 75,
      child: Text(title),
    );
  }

  @override
  Size get preferredSize => Size(75, 75);
}

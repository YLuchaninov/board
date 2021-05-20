import 'package:flutter/material.dart';

class Type1 extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final bool selected;

  const Type1({
    Key? key,
    required this.title,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        color: Colors.purpleAccent,
      ),
      alignment: Alignment.center,
      height: 50,
      width: 100,
      child: Text(title),
    );
  }

  @override
  Size get preferredSize => Size(100, 50);
}

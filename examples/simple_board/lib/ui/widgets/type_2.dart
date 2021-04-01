import 'package:flutter/material.dart';

class Type2 extends StatelessWidget with PreferredSizeWidget{
  final String title;
  final bool selected;

  const Type2({
    Key key,
    @required this.title,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(
          color: selected ? Colors.redAccent : Colors.transparent,
          width: 2,
        ),
      ),
      width: 80,
      height: 40,
      alignment: Alignment.center,
      child: Text(title),
    );
  }

  @override
  Size get preferredSize => Size(80, 40);
}

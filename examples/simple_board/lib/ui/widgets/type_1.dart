import 'package:flutter/material.dart';

class Type1 extends StatelessWidget with PreferredSizeWidget{
  final String title;
  final bool selected;

  const Type1({
    Key key,
    @required this.title,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent,
        border: Border.all(
          color: selected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: Text(title),
    );
  }

  @override
  Size get preferredSize => Size(60, 60);
}

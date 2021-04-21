import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget with PreferredSizeWidget{
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const MenuWidget({Key key, this.onCopy, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: ListTile(
              trailing: Icon(Icons.delete_forever_sharp),
              title: Text('Delete'),
              onTap: onDelete,
            ),
          ),
          Divider(height: 1),
          SizedBox(
            height: 48,
            child: ListTile(
              trailing: Icon(Icons.add),
              title: Text('Make a copy'),
              onTap: onCopy,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size(240, 97);
}
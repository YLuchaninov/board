import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget with PreferredSizeWidget{
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            trailing: Icon(Icons.delete_forever_sharp),
            title: Text('Delete'),
            onTap: (){
              // todo
            },
          ),
          Divider(height: 1),
          ListTile(
            trailing: Icon(Icons.add),
            title: Text('Make a copy'),
            onTap: (){
              // todo
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size(240, 100);
}
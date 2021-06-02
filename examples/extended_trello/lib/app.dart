import 'package:flutter/material.dart';

import 'ui/index.dart';

class TrelloApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extended Trello Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: BoardScreen(),
    );
  }
}
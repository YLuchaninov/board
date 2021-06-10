import 'package:flutter/material.dart';

import 'ui/index.dart';
import 'logic/index.dart';

class TrelloApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BLoC>(
      child: MaterialApp(
        title: 'Extended Trello Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: BoardScreen(),
      ),
      builder: (_, bloc) => bloc ?? BLoC(),
      onDispose: (_, bloc) => bloc.dispose(),
    );
  }
}
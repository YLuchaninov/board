import 'package:flutter/material.dart';

import 'ui/screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stick to Grid',
      home: HomeScreen(),
    );
  }
}
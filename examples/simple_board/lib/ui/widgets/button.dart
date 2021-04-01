import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const ToolButton({
    Key key,
    @required this.title,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: OutlinedButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

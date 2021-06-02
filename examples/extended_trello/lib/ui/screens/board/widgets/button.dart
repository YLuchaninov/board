import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const ToolButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Tooltip(
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.all(Radius.circular(6))
        ),
        message: tooltip,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            child: Icon(icon, size: 18),
          ),
        ),
      ),
    );
  }
}

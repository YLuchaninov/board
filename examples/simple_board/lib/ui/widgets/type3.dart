import 'package:flutter/material.dart';

class InputNode extends StatefulWidget with PreferredSizeWidget{
  final bool selected;
  final bool enabled;
  final String text;
  final String title;
  final ValueChanged<String>? onTextChange;

  const InputNode({
    Key? key,
    required this.text,
    required this.title,
    this.onTextChange,
    this.selected = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  _InputNodeState createState() => _InputNodeState();

  @override
  Size get preferredSize => Size.fromWidth(240);
}

class _InputNodeState extends State<InputNode> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  late String text;
  late bool selected;

  @override
  void initState() {
    if (widget.selected) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }
    selected = widget.selected;

    text = widget.text;
    controller.text = widget.text;
    controller.addListener(onChange);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant InputNode oldWidget) {
    if (widget.text != controller.text) {
      setState(() {
        text = widget.text;
        controller.text = widget.text;
      });
    }

    if(widget.selected != selected) {
      selected = widget.selected;
      if (widget.selected) {
        focusNode.requestFocus();
      } else {
        focusNode.unfocus();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.removeListener(onChange);
    controller.dispose();
    super.dispose();
  }

  onChange() {
    if (text != controller.text) {
      text = controller.text;
      widget.onTextChange?.call(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        border: Border.all(
          color: widget.selected ? Colors.blueAccent : Colors.transparent,
          width: 2,
        ),
      ),
      width: 240,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title),
            SizedBox(
              height: 8,
            ),
            TextField(
              enabled: widget.enabled,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a Text',
              ),
              controller: controller,
              focusNode: focusNode,
            ),
          ],
        ),
      ),
    );
  }
}

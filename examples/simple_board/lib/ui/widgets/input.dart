import 'package:flutter/material.dart';

class InputNode extends StatefulWidget with PreferredSizeWidget{
  final bool selected;
  final String text;
  final ValueChanged<String> onTextChange;

  const InputNode({
    Key key,
    this.text,
    this.selected = false,
    this.onTextChange,
  }) : super(key: key);

  @override
  _InputNodeState createState() => _InputNodeState();

  @override
  Size get preferredSize => Size.fromWidth(240);
}

class _InputNodeState extends State<InputNode> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String text;

  @override
  void initState() {
    if (widget.selected) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
    }

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

    if (widget.selected) {
      focusNode.requestFocus();
    } else {
      focusNode.unfocus();
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
        color: Colors.yellow,
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
            Text('Editable Text'),
            SizedBox(
              height: 8,
            ),
            TextField(
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

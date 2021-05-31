import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'connection_painter.dart';
import 'connection.dart';
import 'paints/debug_paint.dart';

const double _tapTolerance = 10;

class PaintSelector<T> extends StatelessWidget {
  final Widget child;
  final ValueChanged<Connection<T>?> onTap;
  final GlobalKey viewPortKey;
  final List<AnchorConnection<T>> connections;
  final ConnectionPainter painter;
  final TransformationController transformationController;
  final bool showTapZones;

  const PaintSelector({
    Key? key,
    required this.child,
    required this.onTap,
    required this.viewPortKey,
    required this.connections,
    required this.painter,
    required this.transformationController,
    required this.showTapZones,
  }) : super(key: key);

  _onTap(Offset offset) async {
    // todo refactor
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // cut by view port
    final translation = transformationController.value.getTranslation();
    final scale = transformationController.value.getMaxScaleOnAxis();
    final viewPortBox =
        viewPortKey.currentContext!.findRenderObject() as RenderBox;
    final viewPortSize = viewPortBox.size;
    final viewPortLeftTop = Offset(translation.x, translation.y);
    final _width = viewPortSize.width ~/ scale;
    final _height = viewPortSize.height ~/ scale;

    // draw connections
    int color = 1;
    connections.forEach((connection) {
      final data = painter.getPaintDate<T>(
        connection.connection,
        connection.start + viewPortLeftTop / scale,
        connection.end + viewPortLeftTop / scale,
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..isAntiAlias = false
        ..strokeWidth = data.paint.strokeWidth + _tapTolerance
        ..color = Color(color).withOpacity(1.0);

      canvas.drawPath(data.path, paint);
      color += 1;
    });

    // get buffer pixel color
    final img = await pictureRecorder.endRecording().toImage(_width, _height);
    final imgData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final pixelColor = _pixelColorAt(
      byteData: imgData,
      x: (offset.dx + viewPortLeftTop.dx / scale).toInt(),
      y: (offset.dy + viewPortLeftTop.dy / scale).toInt(),
      width: _width,
    );

    img.dispose();

    // get connection by color
    if (pixelColor.value > 0) {
      final index = pixelColor.withOpacity(0).value - 1; // color started from 1
      if (index >= 0 && index < connections.length) {
        onTap(connections[index].connection);
        return;
      }
    }
    onTap(null);
  }

  Widget buildChild(BuildContext context) {
    if (showTapZones)
      return CustomPaint(
        foregroundPainter: DebugPainter(
          connections: connections,
          painter: painter,
          tapTolerance: _tapTolerance,
        ),
        child: child,
      );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer instance) {
            instance..onTapUp = (details) => _onTap(details.localPosition);
          },
        ),
      },
      child: buildChild(context),
    );
  }

  Color _pixelColorAt(
      {required ByteData? byteData,
      required int x,
      required int y,
      required int width}) {
    final byteOffset = 4 * (x + (y * width));
    return Color(_rgbaToArgb(byteData!.getUint32(byteOffset)));
  }

  int _rgbaToArgb(int rgbaColor) {
    int a = rgbaColor & 0xFF;
    int rgb = rgbaColor >> 8;
    return rgb + (a << 24);
  }
}

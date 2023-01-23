import 'package:flutter/material.dart';
import 'package:native_image_cropper/src/crop_layer/layer.dart';

class CropOvalLayer extends CropLayer {
  const CropOvalLayer({
    required super.rect,
    required super.layerOptions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & size;

    final Path areaPath = Path()..addOval(rect);
    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      areaPath,
    );
    canvas
      ..drawPath(maskPath, backgroundPaint)
      ..drawPath(areaPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

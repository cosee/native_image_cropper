import 'package:flutter/material.dart';
import 'package:native_image_cropper/src/mask/mask.dart';

class OvalMask extends CropMask {
  const OvalMask({
    required super.rect,
    required super.maskOptions,
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
}

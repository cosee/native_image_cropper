import 'package:flutter/material.dart';
import 'package:native_image_cropper/src/mask/options.dart';

abstract class CropMask extends CustomPainter {
  const CropMask({
    required this.rect,
    required this.maskOptions,
  });

  final Rect rect;
  final MaskOptions maskOptions;

  Paint get backgroundPaint => Paint()..color = maskOptions.backgroundColor;

  Paint get borderPaint => Paint()
    ..color = maskOptions.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = maskOptions.strokeWidth;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

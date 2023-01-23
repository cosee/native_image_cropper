import 'package:flutter/material.dart';
import 'package:native_image_cropper/src/crop_layer/options.dart';

abstract class CropLayer extends CustomPainter {
  const CropLayer({
    required this.rect,
    required this.layerOptions,
  });

  final Rect rect;
  final CropLayerOptions layerOptions;
  Paint get backgroundPaint => Paint()..color = layerOptions.backgroundColor;

  Paint get borderPaint => Paint()
    ..color = layerOptions.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = layerOptions.strokeWidth;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

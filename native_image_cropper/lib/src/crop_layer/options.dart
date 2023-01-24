import 'package:flutter/material.dart';

class CropLayerOptions {
  const CropLayerOptions({
    this.backgroundColor = Colors.black38,
    this.borderColor = Colors.grey,
    this.strokeWidth = 2,
    this.aspectRatio,
    this.minSize = 0,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double strokeWidth;
  final double? aspectRatio;
  final double minSize;
}

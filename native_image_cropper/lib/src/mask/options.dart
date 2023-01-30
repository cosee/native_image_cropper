import 'package:flutter/material.dart';

class MaskOptions {
  const MaskOptions({
    this.backgroundColor = Colors.black38,
    this.borderColor = Colors.grey,
    this.strokeWidth = 2,
    this.aspectRatio,
    this.minSize = 0,
  }) : assert(
          aspectRatio == null || aspectRatio > 0,
          'Aspect ratio must be greater than 0.',
        );

  final Color backgroundColor;
  final Color borderColor;
  final double strokeWidth;
  final double? aspectRatio;
  final double minSize;
}

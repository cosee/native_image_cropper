import 'package:flutter/material.dart';

class CropLayerOptions {
  const CropLayerOptions({
    this.backgroundColor = Colors.black38,
    this.borderColor = Colors.grey,
    this.strokeWidth = 2,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double strokeWidth;
}

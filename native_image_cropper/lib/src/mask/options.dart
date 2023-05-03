import 'package:flutter/material.dart';

/// The [MaskOptions] defines the appearance and behaviour of the crop mask.
@immutable
class MaskOptions {
  /// Constructs a [MaskOptions].
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

  /// The color of the masked area.
  final Color backgroundColor;

  /// The color of the border that outlines the cropped area.
  final Color borderColor;

  /// The width of the border in pixels.
  final double strokeWidth;

  /// The aspect ratio of the cropped area.
  final double? aspectRatio;

  /// The minimum size allowed for the cropped area.
  final double minSize;

  @override
  String toString() =>
      'MaskOptions{backgroundColor: $backgroundColor, borderColor: '
      '$borderColor, strokeWidth: $strokeWidth, aspectRatio: $aspectRatio, '
      'minSize: $minSize}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaskOptions &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          strokeWidth == other.strokeWidth &&
          aspectRatio == other.aspectRatio &&
          minSize == other.minSize;

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        borderColor,
        strokeWidth,
        aspectRatio,
        minSize,
      );
}

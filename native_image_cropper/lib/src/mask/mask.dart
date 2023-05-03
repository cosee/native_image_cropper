import 'package:flutter/material.dart';
import 'package:native_image_cropper/src/mask/options.dart';

/// The [CropMask] is a custom painter that is used to render the overlay mask
/// in an image cropping widget.
abstract class CropMask extends CustomPainter {
  /// Constructs a [CropMask].
  const CropMask({
    required this.rect,
    required this.maskOptions,
  });

  /// Defines the size and position of the mask.
  final Rect rect;

  /// Options for customizing the appearance of the mask.
  final MaskOptions maskOptions;

  /// Gets a [Paint] object with its color set to the background color
  /// of the [maskOptions].
  Paint get backgroundPaint => Paint()..color = maskOptions.backgroundColor;

  /// Gets a [Paint] object with its color set to the border color of the
  /// [maskOptions], style set to [PaintingStyle.stroke] and stroke width set
  /// to the stroke width of the [maskOptions].
  Paint get borderPaint => Paint()
    ..color = maskOptions.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = maskOptions.strokeWidth;

  @override
  bool shouldRepaint(CropMask oldDelegate) =>
      oldDelegate.rect != rect || oldDelegate.maskOptions != maskOptions;
}

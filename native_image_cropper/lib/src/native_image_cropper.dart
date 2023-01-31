import 'dart:typed_data';

import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// Utility class for cropping images in a native platform.
class NativeImageCropper {
  const NativeImageCropper._();

  /// Completes with a [Uint8List] of the cropped bytes in a rectangle shape.
  static Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) =>
      NativeImageCropperPlatform.instance.cropRect(
        bytes: bytes,
        x: x,
        y: y,
        width: width,
        height: height,
      );

  /// Completes with a [Uint8List] of the cropped bytes in a oval shape.
  static Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) =>
      NativeImageCropperPlatform.instance.cropOval(
        bytes: bytes,
        x: x,
        y: y,
        width: width,
        height: height,
      );
}

import 'package:flutter/foundation.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// [NativeImageCropper] mixin for the purpose of creating mocks.
@visibleForTesting
base mixin MockNativeImagerCropper implements NativeImageCropper {}

/// Utility class for cropping images in a native platform.
final class NativeImageCropper {
  const NativeImageCropper._();

  /// Completes with a [Uint8List] of the cropped bytes in a rectangle shape.
  static Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
    ImageFormat format = ImageFormat.jpg,
  }) =>
      NativeImageCropperPlatform.instance.cropRect(
        bytes: bytes,
        x: x,
        y: y,
        width: width,
        height: height,
        format: format,
      );

  /// Completes with a [Uint8List] of the cropped bytes in an oval shape.
  static Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
    ImageFormat format = ImageFormat.jpg,
  }) =>
      NativeImageCropperPlatform.instance.cropOval(
        bytes: bytes,
        x: x,
        y: y,
        width: width,
        height: height,
        format: format,
      );
}

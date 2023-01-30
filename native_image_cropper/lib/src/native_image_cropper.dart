import 'dart:typed_data';

import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

class NativeImageCropper {
  const NativeImageCropper._();

  static Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    return NativeImageCropperPlatform.instance.cropRect(
      bytes: bytes,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  static Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    return NativeImageCropperPlatform.instance.cropOval(
      bytes: bytes,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }
}

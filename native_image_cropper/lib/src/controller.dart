import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

class CropController {
  final imageSizeNotifier = ValueNotifier<Size?>(null);
  final modeNotifier = ValueNotifier<CropMode>(CropMode.rect);
  final imageRectNotifier = ValueNotifier<Rect?>(null);
  final cropRectNotifier = ValueNotifier<Rect?>(null);
  Uint8List? bytes;

  Size? get imageSize => imageSizeNotifier.value;

  set imageSize(Size? value) => imageSizeNotifier.value = value;

  Rect? get imageRect => imageRectNotifier.value;

  set imageRect(Rect? value) => imageRectNotifier.value = value;

  Rect? get cropRect => cropRectNotifier.value;

  set cropRect(Rect? value) => cropRectNotifier.value = value;

  CropMode get mode => modeNotifier.value;

  set mode(CropMode value) => modeNotifier.value = value;

  Future<Uint8List> crop() {
    final cropRect = this.cropRect;
    final imageRect = this.imageRect;
    final imageSize = this.imageSize;
    final bytes = this.bytes;
    if (bytes == null ||
        imageSize == null ||
        cropRect == null ||
        imageRect == null) {
      throw NativeImageCropperException(
        'NullPointerException',
        'Bytes, crop rect, image rect or image size are not initialized!',
      );
    }

    final x = cropRect.left / imageRect.width * imageSize.width;
    final y = cropRect.top / imageRect.height * imageSize.height;
    final width = cropRect.width / imageRect.width * imageSize.width;
    final height = cropRect.height / imageRect.height * imageSize.height;

    if (modeNotifier.value == CropMode.oval) {
      return NativeImageCropper.cropOval(
        bytes: bytes,
        x: x.toInt(),
        y: y.toInt(),
        width: width.toInt(),
        height: height.toInt(),
      );
    } else {
      return NativeImageCropper.cropRect(
        bytes: bytes,
        x: x.toInt(),
        y: y.toInt(),
        width: width.toInt(),
        height: height.toInt(),
      );
    }
  }

  void dispose() {
    imageSizeNotifier.dispose();
    imageRectNotifier.dispose();
    cropRectNotifier.dispose();
  }
}

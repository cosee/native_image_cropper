import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// The [CropController] manages the state and behaviour of image cropping.
/// It holds data such as image size, crop mode, image rectangle, and crop
/// rectangle, as well as a reference to the image data.
class CropController {
  /// Stores the size of the image to be cropped.
  final imageSizeNotifier = ValueNotifier<Size?>(null);

  /// Stores the image's position and size within the view.
  final imageRectNotifier = ValueNotifier<Rect?>(null);

  /// Stores the selected crop area within the view.
  final cropRectNotifier = ValueNotifier<Rect?>(null);

  /// Stores the [CropMode] of the image to be cropped.
  final modeNotifier = ValueNotifier<CropMode>(CropMode.rect);

  /// Stores the image data to be cropped.
  Uint8List? bytes;

  /// Gets the image [Size] stored in the [ValueNotifier].
  Size? get imageSize => imageSizeNotifier.value;

  /// Sets the new image [Size] in the [ValueNotifier].
  set imageSize(Size? value) => imageSizeNotifier.value = value;

  /// Gets the image [Rect] stored in the [ValueNotifier].
  Rect? get imageRect => imageRectNotifier.value;

  /// Sets the new image [Rect] in the [ValueNotifier].
  set imageRect(Rect? value) => imageRectNotifier.value = value;

  /// Gets the crop [Rect] stored in the [ValueNotifier].
  Rect? get cropRect => cropRectNotifier.value;

  /// Sets the new crop [Rect] in the [ValueNotifier].
  set cropRect(Rect? value) => cropRectNotifier.value = value;

  /// Gets the [CropMode] stored in the [ValueNotifier].
  CropMode get mode => modeNotifier.value;

  /// Sets the new [CropMode]]in the [ValueNotifier].
  set mode(CropMode value) => modeNotifier.value = value;

  /// Performs the actual cropping by calling the corresponding
  /// [NativeImageCropper] method.
  /// The crop() method calculates the crop coordinates based on the relative
  /// positions of the crop rectangle and the image rectangle.
  Future<Uint8List> crop() {
    final cropRect = this.cropRect;
    final imageRect = this.imageRect;
    final imageSize = this.imageSize;
    final bytes = this.bytes;
    if (bytes == null ||
        imageSize == null ||
        cropRect == null ||
        imageRect == null) {
      throw const NativeImageCropperException(
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

  /// Releases the resources held by the [ValueNotifier].
  void dispose() {
    imageSizeNotifier.dispose();
    imageRectNotifier.dispose();
    cropRectNotifier.dispose();
  }

  @override
  String toString() =>
      'CropController{bytes: ${bytes?.lengthInBytes}, imageSize: $imageSize, '
      'imageRect: $imageRect, cropRect: $cropRect, mode: $mode}';
}

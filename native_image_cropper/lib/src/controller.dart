import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// The [CropController] manages the state and behaviour of image cropping.
/// It holds data such as image size, crop mode, image rectangle, and crop
/// rectangle, as well as a reference to the image data.
final class CropController {
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

  /// Calculates the size of the cropped image.
  Size get cropSize {
    if ((cropRect, imageRect, imageSize)
        case (
          final Rect cropRect,
          final Rect imageRect,
          final Size imageSize,
        )) {
      final width = cropRect.width / imageRect.width * imageSize.width;
      final height = cropRect.height / imageRect.height * imageSize.height;
      return Size(width, height);
    }

    throw const NativeImageCropperException(
      'NullPointerException',
      'Bytes, crop rect, image rect or image size are not initialized!',
    );
  }

  /// Performs the actual cropping by calling the corresponding
  /// [NativeImageCropper] method.
  /// The crop() method calculates the crop coordinates based on the relative
  /// positions of the crop rectangle and the image rectangle.
  /// You can additionally set the [ImageFormat] for compression, defaults to
  /// [ImageFormat.jpg].
  Future<Uint8List> crop({ImageFormat format = ImageFormat.jpg}) {
    if ((cropRect, imageRect, imageSize, bytes)
        case (
          final Rect cropRect,
          final Rect imageRect,
          final Size imageSize,
          final Uint8List bytes,
        )) {
      final x = cropRect.left / imageRect.width * imageSize.width;
      final y = cropRect.top / imageRect.height * imageSize.height;
      final width = cropSize.width.toInt();
      final height = cropSize.height.toInt();

      return switch (modeNotifier.value) {
        CropMode.oval => NativeImageCropper.cropOval(
            bytes: bytes,
            x: x.toInt(),
            y: y.toInt(),
            width: width,
            height: height,
            format: format,
          ),
        CropMode.rect => NativeImageCropper.cropRect(
            bytes: bytes,
            x: x.toInt(),
            y: y.toInt(),
            width: width,
            height: height,
            format: format,
          ),
      };
    }

    throw const NativeImageCropperException(
      'NullPointerException',
      'Bytes, crop rect, image rect or image size are not initialized!',
    );
  }

  /// Releases the resources held by the [ValueNotifier].
  void dispose() {
    imageSizeNotifier.dispose();
    imageRectNotifier.dispose();
    cropRectNotifier.dispose();
    modeNotifier.dispose();
  }

  @override
  String toString() =>
      'CropController{bytes: ${bytes?.lengthInBytes}, imageSize: $imageSize, '
      'imageRect: $imageRect, cropRect: $cropRect, mode: $mode}';
}

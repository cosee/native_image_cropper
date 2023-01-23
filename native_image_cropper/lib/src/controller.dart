import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:native_image_cropper/native_image_cropper.dart';

class CropValue {
  const CropValue({
    required this.imageSize,
    required this.imageRect,
    required this.cropRect,
    required this.bytes,
    required this.mode,
  });

  static final CropValue zero = CropValue(
    imageSize: Size.zero,
    imageRect: Rect.zero,
    cropRect: Rect.zero,
    bytes: Uint8List.fromList([]),
    mode: CropMode.rect,
  );

  final Size imageSize;
  final Rect imageRect;
  final Rect cropRect;
  final Uint8List bytes;
  final CropMode mode;

  CropValue copyWith({
    Size? imageSize,
    Rect? imageRect,
    Rect? cropRect,
    Uint8List? bytes,
    CropMode? mode,
  }) =>
      CropValue(
        imageSize: imageSize ?? this.imageSize,
        imageRect: imageRect ?? this.imageRect,
        cropRect: cropRect ?? this.cropRect,
        bytes: bytes ?? this.bytes,
        mode: mode ?? this.mode,
      );

  @override
  String toString() =>
      'CropValue{imageSize: $imageSize, imageRect: $imageRect, '
      'cropRect: $cropRect, bytes: $bytes, mode: $mode}';
}

class CropController extends ValueNotifier<CropValue> {
  CropController() : super(CropValue.zero);

  Future<Uint8List> crop() {
    final imageSize = value.imageSize;
    final imageRect = value.imageRect;
    final cropRect = value.cropRect;
    final x = cropRect.left / imageRect.width * imageSize.width;
    final y = cropRect.top / imageRect.height * imageSize.height;
    final width = cropRect.width / imageRect.width * imageSize.width;
    final height = cropRect.height / imageRect.height * imageSize.height;

    if (value.mode == CropMode.oval) {
      return NativeImageCropper.cropOval(
        bytes: value.bytes,
        x: x.toInt(),
        y: y.toInt(),
        width: width.toInt(),
        height: height.toInt(),
      );
    } else {
      return NativeImageCropper.cropRect(
        bytes: value.bytes,
        x: x.toInt(),
        y: y.toInt(),
        width: width.toInt(),
        height: height.toInt(),
      );
    }
  }

  void updateValue({
    Size? imageSize,
    Rect? imageRect,
    Rect? cropRect,
    Uint8List? bytes,
    CropMode? mode,
  }) =>
      value = value.copyWith(
        imageSize: imageSize,
        imageRect: imageRect,
        cropRect: cropRect,
        bytes: bytes,
        mode: mode,
      );
}

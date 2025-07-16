import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// The Web implementation of [NativeImageCropperPlatform].
final class NativeImageCropperPlugin extends NativeImageCropperPlatform {
  /// Registers this class as the default instance
  /// of [NativeImageCropperPlatform].
  static void registerWith(Registrar _) =>
      NativeImageCropperPlatform.instance = NativeImageCropperPlugin();

  @override
  Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
    ImageFormat format = ImageFormat.jpg,
  }) async {
    final image = await decodeImageFromList(bytes);
    final recorder = PictureRecorder();
    Canvas(recorder).drawImageRect(
      image,
      Rect.fromLTRB(
        x.toDouble(),
        y.toDouble(),
        x.toDouble() + width.toDouble(),
        y.toDouble() + height.toDouble(),
      ),
      Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    final croppedImage = recorder.endRecording().toImageSync(width, height);
    return _convertImageToPng(croppedImage);
  }

  @override
  Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
    ImageFormat format = ImageFormat.jpg,
  }) async {
    final image = await decodeImageFromList(bytes);
    final recorder = PictureRecorder();
    final circlePath = Path()
      ..addOval(
        Rect.fromLTRB(
          0,
          0,
          width.toDouble(),
          height.toDouble(),
        ),
      );
    Canvas(recorder)
      ..clipPath(circlePath)
      ..drawImageRect(
        image,
        Rect.fromLTRB(
          x.toDouble(),
          y.toDouble(),
          x.toDouble() + width.toDouble(),
          y.toDouble() + height.toDouble(),
        ),
        Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()),
        Paint(),
      );

    final croppedImage = recorder.endRecording().toImageSync(width, height);
    return _convertImageToPng(croppedImage);
  }

  Future<Uint8List> _convertImageToPng(Image image) async {
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData == null) {
      return _throwConvertImageError();
    }

    return byteData.buffer.asUint8List();
  }

  Never _throwConvertImageError() => throw const NativeImageCropperException(
    'Convert image',
    'Could not convert image to Uint8List!',
  );
}

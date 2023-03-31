import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// The Web implementation of [NativeImageCropperPlatform].
class NativeImageCropperPlugin extends NativeImageCropperPlatform {
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
    final byteData = await recorder
        .endRecording()
        .toImageSync(width, height)
        .toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      return Uint8List.view(byteData.buffer);
    } else {
      throw const NativeImageCropperException(
        'Convert image',
        'Could not convert image to Uint8List',
      );
    }
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
    final byteData = await recorder
        .endRecording()
        .toImageSync(width, height)
        .toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      return Uint8List.view(byteData.buffer);
    } else {
      throw const NativeImageCropperException(
        'Convert image',
        'Could not convert image to Uint8List',
      );
    }
  }
}

import 'dart:ui';

import 'package:flutter/painting.dart';
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
      return byteData.buffer.asUint8List();
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
    final byteData = await croppedImage.toByteData();
    if (byteData != null) {
      return byteData.buffer.asUint8List();
    } else {
      throw const NativeImageCropperException(
        'Convert image',
        'Could not convert image to Uint8List',
      );
    }
  }
}

class Jpg {
  const Jpg._();

  static Uint8List colorSpaceConversion(Uint8List rgb) {
    final yCbCr = Uint8List(rgb.length);

    for (int i = 0; i < rgb.length; i += 3) {
      final r = rgb[i];
      final g = rgb[i + 1];
      final b = rgb[i + 2];

      final y = 16 + (r * 0.299 + g * 0.587 + b * 0.114).round();
      final cb = 128 + (r * -0.168736 - g * 0.331264 + b * 0.5).round();
      final cr = 128 + (r * 0.5 - g * 0.418688 - b * 0.081312).round();
      yCbCr[i] = y;
      yCbCr[i + 1] = cb;
      yCbCr[i + 2] = cr;
    }

    return yCbCr;
  }

  static List<List<Uint8List>> blockSplitting({
    required Uint8List yCbCr,
    required int width,
    required int height,
  }) {
    final numBlocksX = (width / 8).ceil();
    final numBlocksY = (height / 8).ceil();

    final blocks = List.generate(
      numBlocksY,
      (_) => List.generate(numBlocksX, (_) => Uint8List(64)),
    );

    for (var y = 0; y < numBlocksY; y++) {
      for (var x = 0; x < numBlocksX; x++) {
        final block = blocks[y][x];

        for (var i = 0; i < 64; i++) {
          final pixelX = (x * 8) + (i % 8);
          final pixelY = (y * 8) + (i ~/ 8);

          if (pixelX < width && pixelY < height) {
            block[i] = yCbCr[(pixelY * width) + pixelX];
          }
        }
      }
    }

    return blocks;
  }
}

import 'package:flutter/services.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

class NativeImageCropperIOS extends NativeImageCropperPlatform {
  final MethodChannel _methodChannel =
      const MethodChannel('biz.cosee/native_image_cropper_ios');

  static void registerWith() {
    NativeImageCropperPlatform.instance = NativeImageCropperIOS();
  }

  @override
  Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final arguments = <String, dynamic>{
      'bytes': bytes,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
    try {
      final croppedImage =
          await _methodChannel.invokeMethod<Uint8List>('cropRect', arguments);
      return croppedImage!;
    } on PlatformException catch (e) {
      throw NativeImageCropperException(e.code, e.message);
    }
  }

  @override
  Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final arguments = <String, dynamic>{
      'bytes': bytes,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
    try {
      final croppedImage =
          await _methodChannel.invokeMethod<Uint8List>('cropOval', arguments);
      return croppedImage!;
    } on PlatformException catch (e) {
      throw NativeImageCropperException(e.code, e.message);
    }
  }
}

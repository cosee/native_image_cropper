import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

/// An implementation of [NativeImageCropperPlatform] that uses method channels.
class MethodChannelNativeImageCropper extends NativeImageCropperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('biz.cosee/native_image_cropper');

  @override
  Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    final arguments = {
      'bytes': bytes,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
    try {
      final croppedImage =
          await methodChannel.invokeMethod<Uint8List>('cropRect', arguments);
      if (croppedImage == null) {
        throw const NativeImageCropperException(
          'NullPointerException',
          'Method channel cropRect() returns null!',
        );
      }
      return croppedImage;
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
    final arguments = {
      'bytes': bytes,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
    try {
      final croppedImage =
          await methodChannel.invokeMethod<Uint8List>('cropOval', arguments);
      if (croppedImage == null) {
        throw const NativeImageCropperException(
          'NullPointerException',
          'Method channel cropOval() returns null!',
        );
      }
      return croppedImage;
    } on PlatformException catch (e) {
      throw NativeImageCropperException(e.code, e.message);
    }
  }
}

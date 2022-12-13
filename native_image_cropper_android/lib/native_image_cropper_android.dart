import 'dart:typed_data';

import 'package:native_image_cropper_android/native_image_cropper_android_method_channel.dart';
import 'package:native_image_cropper_android/native_image_cropper_android_platform_interface.dart';

class NativeImageCropperAndroid {
  Future<Uint8List?> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    return NativeImageCropperAndroidPlatform.instance
        .cropRect(bytes: bytes, x: x, y: y, width: width, height: height);
  }

  Future<Uint8List?> cropCircle({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    return NativeImageCropperAndroidPlatform.instance
        .cropCircle(bytes: bytes, x: x, y: y, width: width, height: height);
  }

  static void registerWith() {
    NativeImageCropperAndroidPlatform.instance =
        MethodChannelNativeImageCropperAndroid();
  }
}

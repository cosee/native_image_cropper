import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_android/native_image_cropper_android_platform_interface.dart';

/// An implementation of [NativeImageCropperAndroidPlatform] that uses method channels.
class MethodChannelNativeImageCropperAndroid
    extends NativeImageCropperAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('biz.cosee/native_image_cropper');

  @override
  Future<Uint8List?> cropRect({
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
    final croppedImage =
        await methodChannel.invokeMethod<Uint8List>('cropRect', arguments);
    return croppedImage;
  }
}

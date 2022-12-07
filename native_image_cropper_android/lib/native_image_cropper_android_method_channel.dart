import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:native_image_cropper_android/native_image_cropper_android_platform_interface.dart';

/// An implementation of [NativeImageCropperAndroidPlatform] that uses method channels.
class MethodChannelNativeImageCropperAndroid
    extends NativeImageCropperAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_image_cropper_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

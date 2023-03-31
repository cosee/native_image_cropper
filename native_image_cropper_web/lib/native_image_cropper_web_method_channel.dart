import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_image_cropper_web_platform_interface.dart';

/// An implementation of [NativeImageCropperWebPlatform] that uses method channels.
class MethodChannelNativeImageCropperWeb extends NativeImageCropperWebPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_image_cropper_web');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

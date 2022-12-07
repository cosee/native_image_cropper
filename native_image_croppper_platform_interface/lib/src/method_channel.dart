import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper/native_image_cropper_platform_interface.dart';


/// An implementation of [NativeImageCropperPlatform] that uses method channels.
class MethodChannelNativeImageCropper extends NativeImageCropperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('biz.cosee/native_image_cropper');
}

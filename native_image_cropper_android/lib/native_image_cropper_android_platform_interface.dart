import 'dart:typed_data';

import 'package:native_image_cropper_android/native_image_cropper_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NativeImageCropperAndroidPlatform extends PlatformInterface {
  /// Constructs a NativeImageCropperAndroidPlatform.
  NativeImageCropperAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeImageCropperAndroidPlatform _instance =
      MethodChannelNativeImageCropperAndroid();

  /// The default instance of [NativeImageCropperAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeImageCropperAndroid].
  static NativeImageCropperAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeImageCropperAndroidPlatform] when
  /// they register themselves.
  static set instance(NativeImageCropperAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List?> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  });

  Future<Uint8List?> cropCircle({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  });
}

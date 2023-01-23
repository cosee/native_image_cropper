import 'dart:typed_data';

import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NativeImageCropperPlatform extends PlatformInterface {
  /// Constructs a NativeImageCropperPlatform.
  NativeImageCropperPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeImageCropperPlatform _instance =
      MethodChannelNativeImageCropper();

  /// The default instance of [NativeImageCropperPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeImageCropper].
  static NativeImageCropperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeImageCropperPlatform] when
  /// they register themselves.
  static set instance(NativeImageCropperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    throw UnimplementedError('cropRect() is not implemented.');
  }

  Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    throw UnimplementedError('cropOval() is not implemented.');
  }
}

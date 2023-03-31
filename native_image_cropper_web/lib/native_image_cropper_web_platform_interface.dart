import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_image_cropper_web_method_channel.dart';

abstract class NativeImageCropperWebPlatform extends PlatformInterface {
  /// Constructs a NativeImageCropperWebPlatform.
  NativeImageCropperWebPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeImageCropperWebPlatform _instance = MethodChannelNativeImageCropperWeb();

  /// The default instance of [NativeImageCropperWebPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeImageCropperWeb].
  static NativeImageCropperWebPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeImageCropperWebPlatform] when
  /// they register themselves.
  static set instance(NativeImageCropperWebPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

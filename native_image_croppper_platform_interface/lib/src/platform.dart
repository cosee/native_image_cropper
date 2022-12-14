import 'package:native_image_cropper/src/method_channel.dart';
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

  // TODO Crop rect und crop circle hier hinzufügen?
}

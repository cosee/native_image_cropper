import 'dart:typed_data';

import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of native_image_cropper must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as `native_image_cropper` does not consider newly added methods to be
/// breaking changes. Extending this class (using `extends`) ensures that the
/// subclass will get the default implementation, while platform implementations
/// that `implements` this interface will be broken by newly added
/// [NativeImageCropperPlatform] methods.
abstract base class NativeImageCropperPlatform extends PlatformInterface {
  /// Constructs a NativeImageCropperPlatform.
  NativeImageCropperPlatform() : super(token: _token);

  // ignore: no-object-declaration, see https://pub.dev/packages/plugin_platform_interface
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
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Completes with an [Uint8List] of the cropped bytes in a rectangle shape.
  Future<Uint8List> cropRect({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
    ImageFormat format = ImageFormat.jpg,
  }) {
    throw UnimplementedError('cropRect() is not implemented.');
  }

  /// Completes with an [Uint8List] of the cropped bytes in an oval shape.
  Future<Uint8List> cropOval({
    required Uint8List bytes,
    required int x,
    required int y,
    required int width,
    required int height,
    ImageFormat format = ImageFormat.jpg,
  }) {
    throw UnimplementedError('cropOval() is not implemented.');
  }
}

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'native_image_cropper_web_platform_interface.dart';

/// A web implementation of the NativeImageCropperWebPlatform of the NativeImageCropperWeb plugin.
class NativeImageCropperWebWeb extends NativeImageCropperWebPlatform {
  /// Constructs a NativeImageCropperWebWeb
  NativeImageCropperWebWeb();

  static void registerWith(Registrar registrar) {
    NativeImageCropperWebPlatform.instance = NativeImageCropperWebWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}

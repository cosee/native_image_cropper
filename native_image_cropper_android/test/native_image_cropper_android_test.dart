import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';
import 'package:native_image_cropper_android/native_image_cropper_android_method_channel.dart';
import 'package:native_image_cropper_android/native_image_cropper_android_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeImageCropperAndroidPlatform
    with MockPlatformInterfaceMixin
    implements NativeImageCropperAndroidPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Uint8List?> cropRect(
      {required Uint8List bytes,
      required int x,
      required int y,
      required int width,
      required int height}) {
    // TODO: implement cropRect
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> cropCircle(
      {required Uint8List bytes,
      required int x,
      required int y,
      required int width,
      required int height}) {
    // TODO: implement cropCircle
    throw UnimplementedError();
  }
}

void main() {
  final NativeImageCropperAndroidPlatform initialPlatform =
      NativeImageCropperAndroidPlatform.instance;

  test('$MethodChannelNativeImageCropperAndroid is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelNativeImageCropperAndroid>(),
    );
  });

  /*test('getPlatformVersion', () async {
    final NativeImageCropperAndroid nativeImageCropperAndroidPlugin =
        NativeImageCropperAndroid();
    final MockNativeImageCropperAndroidPlatform fakePlatform =
        MockNativeImageCropperAndroidPlatform();
    NativeImageCropperAndroidPlatform.instance = fakePlatform;

    expect(await nativeImageCropperAndroidPlugin.getPlatformVersion(), '42');
  });

   */
}

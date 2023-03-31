import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper_web/native_image_cropper_web.dart';
import 'package:native_image_cropper_web/native_image_cropper_web_platform_interface.dart';
import 'package:native_image_cropper_web/native_image_cropper_web_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeImageCropperWebPlatform
    with MockPlatformInterfaceMixin
    implements NativeImageCropperWebPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeImageCropperWebPlatform initialPlatform = NativeImageCropperWebPlatform.instance;

  test('$MethodChannelNativeImageCropperWeb is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeImageCropperWeb>());
  });

  test('getPlatformVersion', () async {
    NativeImageCropperWeb nativeImageCropperWebPlugin = NativeImageCropperWeb();
    MockNativeImageCropperWebPlatform fakePlatform = MockNativeImageCropperWebPlatform();
    NativeImageCropperWebPlatform.instance = fakePlatform;

    expect(await nativeImageCropperWebPlugin.getPlatformVersion(), '42');
  });
}

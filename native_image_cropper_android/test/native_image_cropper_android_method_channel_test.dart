import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper_android/native_image_cropper_android_method_channel.dart';

void main() {
  final MethodChannelNativeImageCropperAndroid platform =
      MethodChannelNativeImageCropperAndroid();
  const MethodChannel channel = MethodChannel('native_image_cropper_android');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

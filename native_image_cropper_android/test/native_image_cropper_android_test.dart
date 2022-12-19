import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';

import 'method_channel_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers instance', () async {
    NativeImageCropperAndroid.registerWith();
    expect(
      NativeImageCropperPlatform.instance,
      isA<NativeImageCropperAndroid>(),
    );
  });

  group('cropRect', () {
    test('Should send cropping data and receive back a Uint8List', () async {
      final MethodChannelMock mockChannel = MethodChannelMock(
        methods: {
          'cropRect': Uint8List.fromList([0, 0]),
        },
      );
      final NativeImageCropperAndroid cropper = NativeImageCropperAndroid();
      final Uint8List croppedBytes = await cropper.cropRect(
        bytes: Uint8List.fromList([0, 0, 0, 0]),
        x: 0,
        y: 0,
        width: 1,
        height: 1,
      );
      expect(mockChannel.log, [
        isMethodCall(
          'cropRect',
          arguments: {
            'bytes': Uint8List.fromList([0, 0, 0, 0]),
            'x': 0,
            'y': 0,
            'width': 1,
            'height': 1,
          },
        ),
      ]);
      expect(croppedBytes, Uint8List.fromList([0, 0]));
    });
    test(
      'Should throw an NativeImageCropperException when cropRect throws a PlatformException',
      () async {
        MethodChannelMock(
          methods: {
            'cropRect': PlatformException(
              code: 'Test Error',
              message: 'This is a test.',
            ),
          },
        );
        final NativeImageCropperAndroid cropper = NativeImageCropperAndroid();

        expect(
          () => cropper.cropRect(
            bytes: Uint8List.fromList([0, 0, 0, 0]),
            x: 0,
            y: 0,
            width: 1,
            height: 1,
          ),
          throwsA(
            isA<NativeImageCropperException>()
                .having((e) => e.code, 'code', 'Test Error')
                .having((e) => e.description, 'description', 'This is a test.'),
          ),
        );
      },
    );
  });

  group('cropCircle', () {
    test('Should send cropping data and receive back a Uint8List', () async {
      final MethodChannelMock mockChannel = MethodChannelMock(
        methods: {
          'cropCircle': Uint8List.fromList([0, 0]),
        },
      );
      final NativeImageCropperAndroid cropper = NativeImageCropperAndroid();
      final Uint8List croppedBytes = await cropper.cropCircle(
        bytes: Uint8List.fromList([0, 0, 0, 0]),
        x: 0,
        y: 0,
        width: 1,
        height: 1,
      );
      expect(mockChannel.log, [
        isMethodCall(
          'cropCircle',
          arguments: {
            'bytes': Uint8List.fromList([0, 0, 0, 0]),
            'x': 0,
            'y': 0,
            'width': 1,
            'height': 1,
          },
        ),
      ]);
      expect(croppedBytes, Uint8List.fromList([0, 0]));
    });
    test(
      'Should throw an NativeImageCropperException when cropCircle throws a PlatformException',
      () async {
        MethodChannelMock(
          methods: {
            'cropCircle': PlatformException(
              code: 'Test Error',
              message: 'This is a test.',
            ),
          },
        );
        final NativeImageCropperAndroid cropper = NativeImageCropperAndroid();

        expect(
          () => cropper.cropCircle(
            bytes: Uint8List.fromList([0, 0, 0, 0]),
            x: 0,
            y: 0,
            width: 1,
            height: 1,
          ),
          throwsA(
            isA<NativeImageCropperException>()
                .having((e) => e.code, 'code', 'Test Error')
                .having((e) => e.description, 'description', 'This is a test.'),
          ),
        );
      },
    );
  });
}

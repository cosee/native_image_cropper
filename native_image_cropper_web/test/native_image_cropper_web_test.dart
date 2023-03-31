import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper_platform_interface/native_image_cropper_platform_interface.dart';
import 'package:native_image_cropper_web/native_image_cropper_web.dart';

import 'method_channel_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Registers instance', () {
    NativeImageCropperWeb.registerWith();
    expect(
      NativeImageCropperPlatform.instance,
      isA<NativeImageCropperWeb>(),
    );
  });

  group('cropRect', () {
    test('Should send cropping data and receive back a Uint8List', () async {
      final MethodChannelMock mockChannel = MethodChannelMock(
        methods: {
          'cropRect': Uint8List.fromList([0, 0]),
        },
      );
      final cropper = NativeImageCropperWeb();
      final croppedBytes = await cropper.cropRect(
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
            'imageFormat': 'jpg',
          },
        ),
      ]);
      expect(croppedBytes, Uint8List.fromList([0, 0]));
    });
    test(
      'Should throw an NativeImageCropperException when cropRect throws a '
      'PlatformException',
      () {
        MethodChannelMock(
          methods: {
            'cropRect': PlatformException(
              code: 'Test Error',
              message: 'This is a test.',
            ),
          },
        );
        final NativeImageCropperWeb cropper = NativeImageCropperWeb();

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

  group('cropOval', () {
    test('Should send cropping data and receive back a Uint8List', () async {
      final MethodChannelMock mockChannel = MethodChannelMock(
        methods: {
          'cropOval': Uint8List.fromList([0, 0]),
        },
      );
      final cropper = NativeImageCropperWeb();
      final croppedBytes = await cropper.cropOval(
        bytes: Uint8List.fromList([0, 0, 0, 0]),
        x: 0,
        y: 0,
        width: 1,
        height: 1,
      );
      expect(mockChannel.log, [
        isMethodCall(
          'cropOval',
          arguments: {
            'bytes': Uint8List.fromList([0, 0, 0, 0]),
            'x': 0,
            'y': 0,
            'width': 1,
            'height': 1,
            'imageFormat': 'jpg',
          },
        ),
      ]);
      expect(croppedBytes, Uint8List.fromList([0, 0]));
    });
    test(
      'Should throw an NativeImageCropperException when cropOval throws a '
      'PlatformException',
      () {
        MethodChannelMock(
          methods: {
            'cropOval': PlatformException(
              code: 'Test Error',
              message: 'This is a test.',
            ),
          },
        );
        final cropper = NativeImageCropperWeb();

        expect(
          () => cropper.cropOval(
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

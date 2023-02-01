import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

import '../utils.dart';

void main() {
  const cropUtils = CropUtilsAspectRatioNull(minCropRectSize: 20);

  group('computeImageRect', () {
    test('returns expected Rect without Offset', () {
      const imageSize = Size(1280, 720);
      final actual = cropUtils
          .computeImageRect(
            imageSize: imageSize,
            availableSpace: const Rect.fromLTWH(0, 0, 500, 500),
          )
          .round();
      expect(
        actual,
        const Rect.fromLTRB(0, 0, 500, 281.25).round(),
      );
      expect(
        actual.aspectRatio.roundTwoPlaces(),
        imageSize.aspectRatio.roundTwoPlaces(),
      );
    });

    test('returns expected Rect with Offset', () {
      const imageSize = Size(1280, 720);
      final actual = cropUtils
          .computeImageRect(
            imageSize: const Size(1280, 720),
            availableSpace: const Rect.fromLTWH(100, 50, 400, 450),
          )
          .round();
      expect(
        actual,
        const Rect.fromLTRB(0, 0, 400, 225),
      );
      expect(
        actual.aspectRatio.roundTwoPlaces(),
        imageSize.aspectRatio.roundTwoPlaces(),
      );
    });
  });

  group('moveCropRect', () {
    const imageRect = Rect.fromLTRB(0, 0, 100, 100);
    const cropRect = Rect.fromLTRB(0, 0, 50, 50);
    const delta = Offset(10, 10);
    test(
      'returns null if cropRect is null',
      () => expect(
        cropUtils.moveCropRect(imageRect: imageRect, delta: delta),
        null,
      ),
    );
    test(
      'returns null if imageRect is null',
      () => expect(
        cropUtils.moveCropRect(cropRect: cropRect, delta: delta),
        null,
      ),
    );
    test('return expected Rect if inside boundaries', () {
      final actual = cropUtils.moveCropRect(
        imageRect: imageRect,
        cropRect: cropRect,
        delta: delta,
      );
      expect(actual, const Rect.fromLTRB(10, 10, 60, 60));
    });
    test('return cropRect Rect if outside boundaries', () {
      final actual = cropUtils.moveCropRect(
        imageRect: imageRect,
        cropRect: cropRect,
        delta: -delta,
      );
      expect(actual, cropRect);
    });
  });
}

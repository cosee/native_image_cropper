import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

import '../utils.dart';

void main() {
  const double aspectRatio = 3 / 4;
  const cropUtils = CropUtilsAspectRatioSmallerOne(
    minCropRectSize: 20,
    aspectRatio: aspectRatio,
  );
  const imageRect = Rect.fromLTRB(0, 0, 100, 100);
  const cropRect = Rect.fromLTRB(0, 0, 30, 40);
  const delta = Offset(10, 10);

  group('CropUtilsAspectRatioSmallerOne', () {
    test(
      'throws [AssertionError] if aspect ratio is equals to 1',
      () => expect(
        () => CropUtilsAspectRatioSmallerOne(
          minCropRectSize: 20,
          aspectRatio: 1,
        ),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'Aspect ratio must be smaller than 1!',
          ),
        ),
      ),
    );
    test(
      'throws [AssertionError] if aspect ratio is greater than 1',
      () => expect(
        () => CropUtilsAspectRatioSmallerOne(
          minCropRectSize: 20,
          aspectRatio: 4 / 3,
        ),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'Aspect ratio must be smaller than 1!',
          ),
        ),
      ),
    );
  });

  group('getInitialRect', () {
    test(
      'returns null if imageRect is null',
      () => expect(cropUtils.getInitialRect(null), null),
    );
    test('returns imageRect in the given aspect ratio if not null', () {
      const imageRect = Rect.fromLTRB(0, 0, 100, 100);
      final actual = cropUtils.getInitialRect(imageRect)!;
      expect(actual, const Rect.fromLTRB(12.5, 0, 87.5, 100));
      expect(
        actual.aspectRatio.roundTwoPlaces(),
        aspectRatio.roundTwoPlaces(),
      );
    });
  });

  group('computeCropRectWithNewAspectRatio', () {
    const imageRect = Rect.fromLTRB(0, 0, 100, 100);
    const oldCropRect = Rect.fromLTRB(0, 0, 50, 50);
    test(
      'returns null if oldCropRect is null',
      () => expect(
        cropUtils.computeCropRectWithNewAspectRatio(imageRect: imageRect),
        null,
      ),
    );
    test(
      'returns null if imageRect is null',
      () => expect(
        cropUtils.computeCropRectWithNewAspectRatio(oldCropRect: oldCropRect),
        null,
      ),
    );
    test(
      'returns new crop rect with given aspect ratio if oldCropRect and '
      'imageRect is not null',
      () {
        final actual = cropUtils
            .computeCropRectWithNewAspectRatio(
              oldCropRect: oldCropRect,
              imageRect: imageRect,
            )!
            .round();
        expect(actual, const Rect.fromLTRB(0, 0, 50, 66.67));
        expect(
          actual.aspectRatio.roundTwoPlaces(),
          aspectRatio.roundTwoPlaces(),
        );
      },
    );
  });

  group('moveTopLeftCorner', () {
    test(
      'returns null if cropRect is null',
      () => expect(
        cropUtils.moveTopLeftCorner(imageRect: imageRect, delta: delta),
        null,
      ),
    );
    test(
      'returns null if imageRect is null',
      () => expect(
        cropUtils.moveTopLeftCorner(cropRect: cropRect, delta: delta),
        null,
      ),
    );
    test('Returns expected Rect if inside boundaries', () {
      final actual = cropUtils
          .moveTopLeftCorner(
            cropRect: cropRect,
            imageRect: imageRect,
            delta: delta,
          )
          ?.round();
      expect(actual, const Rect.fromLTRB(7.5, 10, 30, 40));
      expect(
        actual?.aspectRatio.roundTwoPlaces(),
        aspectRatio.roundTwoPlaces(),
      );
    });
    test('Returns cropRect if outside boundaries', () {
      final actual = cropUtils.moveTopLeftCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: -delta,
      );
      expect(actual, cropRect);
    });
  });

  group('moveTopRightCorner', () {
    test(
      'returns null if cropRect is null',
      () => expect(
        cropUtils.moveTopRightCorner(imageRect: imageRect, delta: delta),
        null,
      ),
    );
    test(
      'returns null if imageRect is null',
      () => expect(
        cropUtils.moveTopRightCorner(cropRect: cropRect, delta: delta),
        null,
      ),
    );
    test('Returns expected Rect if inside boundaries', () {
      final actual = cropUtils.moveTopRightCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: delta,
      );
      expect(actual, const Rect.fromLTRB(0, 10, 22.5, 40));
      expect(
        actual?.aspectRatio.roundTwoPlaces(),
        aspectRatio.roundTwoPlaces(),
      );
    });
    test('Returns cropRect if outside boundaries', () {
      final actual = cropUtils.moveTopRightCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: const Offset(0, -10),
      );
      expect(actual, cropRect);
    });
  });

  group('moveBottomLeftCorner', () {
    test(
      'returns null if cropRect is null',
      () => expect(
        cropUtils.moveBottomLeftCorner(imageRect: imageRect, delta: delta),
        null,
      ),
    );
    test(
      'returns null if imageRect is null',
      () => expect(
        cropUtils.moveBottomLeftCorner(cropRect: cropRect, delta: delta),
        null,
      ),
    );
    test('Returns expected Rect if inside boundaries', () {
      final actual = cropUtils.moveBottomLeftCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: const Offset(10, -10),
      );
      expect(actual, const Rect.fromLTRB(7.5, 0, 30, 30));
      expect(
        actual?.aspectRatio.roundTwoPlaces(),
        aspectRatio.roundTwoPlaces(),
      );
    });
    test('Returns cropRect if outside boundaries', () {
      final actual = cropUtils.moveBottomLeftCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: const Offset(100, 100),
      );
      expect(actual, cropRect);
    });
  });

  group('moveBottomRightCorner', () {
    test(
      'returns null if cropRect is null',
      () => expect(
        cropUtils.moveBottomRightCorner(imageRect: imageRect, delta: delta),
        null,
      ),
    );
    test(
      'returns null if imageRect is null',
      () => expect(
        cropUtils.moveBottomRightCorner(cropRect: cropRect, delta: delta),
        null,
      ),
    );
    test('Returns expected Rect if inside boundaries', () {
      final actual = cropUtils.moveBottomRightCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: delta,
      );
      expect(actual, const Rect.fromLTRB(0, 0, 37.5, 50));
      expect(
        actual?.aspectRatio.roundTwoPlaces(),
        aspectRatio.roundTwoPlaces(),
      );
    });
    test('Returns cropRect if outside boundaries', () {
      final actual = cropUtils.moveBottomRightCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: const Offset(100, 100),
      );
      expect(actual, cropRect);
    });
  });
}

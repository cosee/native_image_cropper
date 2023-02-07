import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

import '../utils.dart';

void main() {
  const double aspectRatio = 4 / 3;
  const cropUtils = CropUtilsAspectRatioGreaterEqualsOne(
    minCropRectSize: 20,
    aspectRatio: aspectRatio,
  );

  const imageRect = Rect.fromLTRB(0, 0, 100, 100);
  const cropRect = Rect.fromLTRB(0, 0, 40, 30);
  const delta = Offset(10, 10);

  group('CropUtilsAspectRatioGreaterEqualsOne', () {
    test(
      'throws [AssertionError] if aspect ratio is smaller than 1',
      () => expect(
        () => CropUtilsAspectRatioGreaterEqualsOne(
          minCropRectSize: 20,
          aspectRatio: 3 / 4,
        ),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'Aspect ratio must be greater than or equals to 1!',
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
      expect(actual, const Rect.fromLTRB(0, 12.5, 100, 87.5));
      expect(actual.aspectRatio.roundTwoPlaces(), aspectRatio.roundTwoPlaces());
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
        expect(actual, const Rect.fromLTRB(0, 0, 66.67, 50));
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
      expect(actual, const Rect.fromLTRB(13.33, 10, 40, 30));
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
      final actual = cropUtils
          .moveTopRightCorner(
            cropRect: cropRect,
            imageRect: imageRect,
            delta: delta,
          )
          ?.round();
      expect(actual, const Rect.fromLTRB(0, 10, 26.67, 30));
      expect(
        actual?.aspectRatio.roundTwoPlaces(),
        aspectRatio.roundTwoPlaces(),
      );
    });
    test('Returns cropRect if outside boundaries', () {
      final actual = cropUtils.moveTopRightCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: -delta,
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
      final actual = cropUtils
          .moveBottomLeftCorner(
            cropRect: cropRect,
            imageRect: imageRect,
            delta: const Offset(10, -10),
          )
          ?.round();
      expect(actual, const Rect.fromLTRB(13.33, 0, 40, 20));
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
      final actual = cropUtils
          .moveBottomRightCorner(
            cropRect: cropRect,
            imageRect: imageRect,
            delta: delta,
          )
          ?.round();
      expect(actual, const Rect.fromLTRB(0, 0, 53.33, 40));
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

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

import '../utils.dart';

void main() {
  const cropUtils = CropUtilsAspectRatioNull(minCropRectSize: 20);
  const imageRect = Rect.fromLTRB(0, 0, 100, 100);
  const cropRect = Rect.fromLTRB(0, 0, 50, 50);
  const delta = Offset(10, 10);
  group('getInitialRect', () {
    test(
      'returns null if imageRect is null',
      () => expect(cropUtils.getInitialRect(null), null),
    );
    test('returns imageRect if not null', () {
      const imageRect = Rect.fromLTRB(0, 0, 100, 100);
      expect(cropUtils.getInitialRect(imageRect), imageRect);
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
      'returns oldCropRect if oldCropRect and imageRect is not null',
      () => expect(
        cropUtils.computeCropRectWithNewAspectRatio(
          oldCropRect: oldCropRect,
          imageRect: imageRect,
        ),
        oldCropRect,
      ),
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
      expect(actual, const Rect.fromLTRB(10, 10, 50, 50));
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
      expect(actual, const Rect.fromLTRB(0, 10, 60, 50));
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
            delta: delta,
          )
          ?.round();
      expect(actual, const Rect.fromLTRB(10, 0, 50, 60));
    });
    test('Returns cropRect if outside boundaries', () {
      final actual = cropUtils.moveBottomLeftCorner(
        cropRect: cropRect,
        imageRect: imageRect,
        delta: -delta,
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
      expect(actual, const Rect.fromLTRB(0, 0, 60, 60));
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

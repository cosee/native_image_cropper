import 'package:flutter/rendering.dart';

class CropUtils {
  const CropUtils._();

  static const Size _minCropRectSize = Size(20, 20);

  static Rect computeImageRect({
    required Size imageSize,
    required Rect availableSpace,
  }) {
    final fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, availableSpace.size);
    final destinationSize = fittedSizes.destination;
    return Rect.fromPoints(
      Offset.zero,
      destinationSize.bottomRight(Offset.zero),
    );
  }

  static Rect? moveCropRect({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }
    final newRect = cropRect.shift(delta);
    return constraintCropRect(
      newRect: newRect,
      cropRect: cropRect,
      imageRect: imageRect,
    );
  }

  static Rect constraintCropRect({
    required Rect newRect,
    required Rect cropRect,
    required Rect imageRect,
  }) {
    Rect resultRect = newRect;
    if (resultRect.right > imageRect.right) {
      final dx = imageRect.right - cropRect.right;
      resultRect = Rect.fromPoints(
        cropRect.topLeft + Offset(dx, 0),
        Offset(imageRect.right, cropRect.bottom),
      );
    }

    if (resultRect.left < imageRect.left) {
      final dx = imageRect.left - cropRect.left;
      resultRect = Rect.fromPoints(
        Offset(imageRect.left, cropRect.top),
        cropRect.bottomRight + Offset(dx, 0),
      );
    }

    if (resultRect.top < imageRect.top) {
      final dy = imageRect.top - cropRect.top;
      resultRect = Rect.fromPoints(
        Offset(cropRect.left, imageRect.top),
        cropRect.bottomRight + Offset(0, dy),
      );
    }

    if (resultRect.bottom > imageRect.bottom) {
      final dy = imageRect.bottom - cropRect.bottom;
      resultRect = Rect.fromPoints(
        cropRect.topLeft + Offset(0, dy),
        Offset(cropRect.right, imageRect.bottom),
      );
    }

    return resultRect;
  }

  static Rect? moveTopLeftCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    final newRect =
        Rect.fromPoints(cropRect.topLeft + delta, cropRect.bottomRight);
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static Rect? moveTopRightCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    final newRect = Rect.fromPoints(
      cropRect.topLeft + Offset(0, delta.dy),
      cropRect.bottomRight + Offset(delta.dx, 0),
    );
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static Rect? moveBottomLeftCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    final newRect = Rect.fromPoints(
      cropRect.topLeft + Offset(delta.dx, 0),
      cropRect.bottomRight + Offset(0, delta.dy),
    );
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static Rect? moveBottomRightCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    final newRect =
        Rect.fromPoints(cropRect.topLeft, cropRect.bottomRight + delta);
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static bool _isSmallerThanMinCropRect(Rect rect) =>
      rect.width < _minCropRectSize.width ||
      rect.height < _minCropRectSize.height;
}

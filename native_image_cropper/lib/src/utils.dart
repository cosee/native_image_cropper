import 'package:flutter/rendering.dart';

class CropUtils {
  const CropUtils._();

  static const Size _minCropRectSize = Size(20, 20);

  static Rect computeEffectiveRect(Size imageSize, Rect availableSpace) {
    final fittedSizes =
        applyBoxFit(BoxFit.contain, imageSize, availableSpace.size);
    final destinationSize = fittedSizes.destination;
    return Rect.fromPoints(
      Offset.zero,
      destinationSize.bottomRight(Offset.zero),
    );
  }

  static Rect moveTopLeftCorner({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    final newRect =
        Rect.fromPoints(cropRect.topLeft + delta, cropRect.bottomRight);
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static Rect moveTopRightCorner({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    final newRect = Rect.fromPoints(
      cropRect.topLeft + Offset(0, delta.dy),
      cropRect.bottomRight + Offset(delta.dx, 0),
    );
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static Rect moveBottomLeftCorner({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    final newRect = Rect.fromPoints(
      cropRect.topLeft + Offset(delta.dx, 0),
      cropRect.bottomRight + Offset(0, delta.dy),
    );
    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  static Rect moveBottomRightCorner({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
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

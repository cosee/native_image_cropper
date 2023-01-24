import 'dart:math';

import 'package:flutter/rendering.dart';

class CropUtils {
  const CropUtils({
    required this.minCropRectSize,
    this.aspectRatio,
  });

  final double minCropRectSize;
  final double? aspectRatio;
  static const double _tolerance = 0.1;

  Rect? getInitialRect(Rect? imageRect) {
    if (imageRect == null) {
      return null;
    }

    final ar = aspectRatio;
    if (ar == null) {
      return imageRect;
    }

    if (ar < 1) {
      final width = min(imageRect.width, imageRect.height * ar);
      return Rect.fromCenter(
        center: imageRect.center,
        width: width,
        height: width / ar,
      );
    } else {
      final height = min(imageRect.width / ar, imageRect.height);
      return Rect.fromCenter(
        center: imageRect.center,
        width: height * ar,
        height: height,
      );
    }
  }

  Rect computeImageRect({
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

  Rect? moveCropRect({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    final newRect = _shiftRectConsideringBoundaries(
      imageRect: imageRect,
      cropRect: cropRect,
      delta: delta,
    );

    return _constraintCropRect(
      newRect: newRect,
      cropRect: cropRect,
      imageRect: imageRect,
    );
  }

  Rect _shiftRectConsideringBoundaries({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    if (cropRect.top < _tolerance && delta.dy < 0) {
      return cropRect.shift(Offset(delta.dx, 0));
    } else if (cropRect.bottom > imageRect.height - _tolerance &&
        delta.dy > 0) {
      return cropRect.shift(Offset(delta.dx, 0));
    } else if (cropRect.left < _tolerance && delta.dx < 0) {
      return cropRect.shift(Offset(0, delta.dy));
    } else if (cropRect.right > imageRect.right - _tolerance && delta.dx > 0) {
      return cropRect.shift(Offset(0, delta.dy));
    } else {
      return cropRect.shift(delta);
    }
  }

  static Rect _constraintCropRect({
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

  Rect? moveTopLeftCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newRect =
        Rect.fromPoints(cropRect.topLeft + delta, cropRect.bottomRight);
    final aspectRatioOffset =
        _calculateAspectRatioOffset(cropRect: cropRect, newRect: newRect);
    newRect = Rect.fromPoints(
      newRect.bottomRight - aspectRatioOffset,
      newRect.bottomRight,
    );

    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }

    return imageRect.intersect(newRect);
  }

  Rect? moveTopRightCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newRect = Rect.fromPoints(
      cropRect.topLeft + Offset(0, delta.dy),
      cropRect.bottomRight + Offset(delta.dx, 0),
    );
    final aspectRatioOffset =
        _calculateAspectRatioOffset(cropRect: cropRect, newRect: newRect);
    newRect = Rect.fromPoints(
      newRect.bottomLeft + Offset(0, -aspectRatioOffset.dy),
      newRect.bottomLeft + Offset(aspectRatioOffset.dx, 0),
    );

    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  Rect? moveBottomLeftCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newRect = Rect.fromPoints(
      cropRect.topLeft + Offset(delta.dx, 0),
      cropRect.bottomRight + Offset(0, delta.dy),
    );
    final aspectRatioOffset =
        _calculateAspectRatioOffset(cropRect: cropRect, newRect: newRect);
    newRect = Rect.fromPoints(
      newRect.topRight - Offset(aspectRatioOffset.dx, 0),
      newRect.topRight + Offset(0, aspectRatioOffset.dy),
    );

    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  Rect? moveBottomRightCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newRect =
        Rect.fromPoints(cropRect.topLeft, cropRect.bottomRight + delta);
    final aspectRatioOffset =
        _calculateAspectRatioOffset(cropRect: cropRect, newRect: newRect);
    newRect = Rect.fromPoints(
      newRect.topLeft,
      newRect.topLeft + aspectRatioOffset,
    );

    if (_isSmallerThanMinCropRect(newRect)) {
      return cropRect;
    }
    return imageRect.intersect(newRect);
  }

  Offset _calculateAspectRatioOffset({
    required Rect cropRect,
    required Rect newRect,
  }) {
    final ar = aspectRatio;
    if (ar == null) {
      return Offset(newRect.size.width, newRect.size.height);
    }

    if (ar < 1) {
      double width;
      if (newRect.area < cropRect.area) {
        width = max(newRect.width, newRect.height * ar);
      } else {
        width = min(newRect.width, newRect.height * ar);
      }
      return Offset(width, width / ar);
    } else {
      double height;
      if (newRect.area < cropRect.area) {
        height = max(newRect.width / ar, newRect.height);
      } else {
        height = min(newRect.width / ar, newRect.height);
      }
      return Offset(height * ar, height);
    }
  }

  bool _isSmallerThanMinCropRect(Rect rect) =>
      rect.width < minCropRectSize || rect.height < minCropRectSize;
}

extension on Rect {
  double get area => width * height;
}

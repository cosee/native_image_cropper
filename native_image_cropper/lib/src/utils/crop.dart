import 'dart:math';

import 'package:flutter/rendering.dart';

part 'aspect_greater_equals_one.dart';
part 'aspect_ratio_null.dart';
part 'aspect_smaller_one.dart';

/// The [CropUtils] class is an interface for performing crop operations on an
/// image.
///
/// Classes that are designed for crop utility should inherit from this class.
abstract class CropUtils {
  /// Constructs a [CropUtils]
  const CropUtils({
    required this.minCropRectSize,
  });

  /// Represents the minimum size of the crop rectangle that should be
  /// maintained while cropping an image.
  final double minCropRectSize;

  /// Used to improve the smoothness of the movement of the crop rectangle.
  static const double _tolerance = 0.1;

  /// Returns the initial rect for cropping.
  Rect? getInitialRect(Rect? imageRect);

  /// Returns a new crop [Rect] from an [oldCropRect] after applying
  /// the aspect ratio if given.
  Rect? computeCropRectWithNewAspectRatio({
    Rect? oldCropRect,
    Rect? imageRect,
  });

  /// Calculates the [Offset] needed to maintain the aspect ratio for
  /// the [newCropRect] based on the [oldCropRect].
  Offset _calculateAspectRatioOffset({
    required Rect oldCropRect,
    required Rect newCropRect,
  });

  /// Computes a [Rect] from the given [imageSize] and [availableSpace],
  /// which fits the screen.
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

  /// Move the [cropRect] by the given [delta], considering the boundaries of
  /// the image.
  Rect? moveCropRect({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    final newCropRect = _smoothShiftRect(
      imageRect: imageRect,
      cropRect: cropRect,
      delta: delta,
    );

    return _constraintCropRect(
      newCropRect: newCropRect,
      cropRect: cropRect,
      imageRect: imageRect,
    );
  }

  /// Smoothly shifts the [cropRect] by the given [delta] within
  /// the [imageRect], considering a [_tolerance].
  Rect _smoothShiftRect({
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

  /// Constraints the [newCropRect] to make sure it is within the bounds of
  /// the [imageRect].
  static Rect _constraintCropRect({
    required Rect newCropRect,
    required Rect cropRect,
    required Rect imageRect,
  }) {
    Rect resultRect = newCropRect;
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

  /// Moves the top left corner of the [cropRect] by the given [delta] while
  /// maintaining the aspect ratio and making sure it stays within
  /// the [imageRect].
  Rect? moveTopLeftCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newCropRect =
        Rect.fromPoints(cropRect.topLeft + delta, cropRect.bottomRight);
    final aspectRatioOffset = _calculateAspectRatioOffset(
      oldCropRect: cropRect,
      newCropRect: newCropRect,
    );
    newCropRect = Rect.fromPoints(
      newCropRect.bottomRight - aspectRatioOffset,
      newCropRect.bottomRight,
    );

    if (_isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }

    return imageRect.intersect(newCropRect);
  }

  /// Moves the top right corner of the [cropRect] by the given [delta] while
  /// maintaining the aspect ratio and making sure it stays within
  /// the [imageRect].
  Rect? moveTopRightCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newCropRect = Rect.fromPoints(
      cropRect.topLeft + Offset(0, delta.dy),
      cropRect.bottomRight + Offset(delta.dx, 0),
    );
    final aspectRatioOffset = _calculateAspectRatioOffset(
      oldCropRect: cropRect,
      newCropRect: newCropRect,
    );
    newCropRect = Rect.fromPoints(
      newCropRect.bottomLeft + Offset(0, -aspectRatioOffset.dy),
      newCropRect.bottomLeft + Offset(aspectRatioOffset.dx, 0),
    );

    if (_isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }
    return imageRect.intersect(newCropRect);
  }

  /// Moves the bottom left corner of the [cropRect] by the given [delta] while
  /// maintaining the aspect ratio and making sure it stays within
  /// the [imageRect].
  Rect? moveBottomLeftCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newCropRect = Rect.fromPoints(
      cropRect.topLeft + Offset(delta.dx, 0),
      cropRect.bottomRight + Offset(0, delta.dy),
    );
    final aspectRatioOffset = _calculateAspectRatioOffset(
      oldCropRect: cropRect,
      newCropRect: newCropRect,
    );
    newCropRect = Rect.fromPoints(
      newCropRect.topRight - Offset(aspectRatioOffset.dx, 0),
      newCropRect.topRight + Offset(0, aspectRatioOffset.dy),
    );

    if (_isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }
    return imageRect.intersect(newCropRect);
  }

  /// Moves the bottom right corner of the [cropRect] by the given [delta] while
  /// maintaining the aspect ratio and making sure it stays within
  /// the [imageRect].
  Rect? moveBottomRightCorner({
    Rect? cropRect,
    Rect? imageRect,
    required Offset delta,
  }) {
    if (cropRect == null || imageRect == null) {
      return null;
    }

    Rect newCropRect =
        Rect.fromPoints(cropRect.topLeft, cropRect.bottomRight + delta);
    final aspectRatioOffset = _calculateAspectRatioOffset(
      oldCropRect: cropRect,
      newCropRect: newCropRect,
    );
    newCropRect = Rect.fromPoints(
      newCropRect.topLeft,
      newCropRect.topLeft + aspectRatioOffset,
    );

    if (_isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }
    return imageRect.intersect(newCropRect);
  }

  /// Checks if the width or height of the [rect] is less
  /// than [minCropRectSize].
  bool _isSmallerThanMinCropRect(Rect rect) =>
      rect.width < minCropRectSize || rect.height < minCropRectSize;
}

extension on Rect {
  /// Calculates the area of a [Rect] by returning the product of
  /// [width] and [height].
  double get area => width * height;
}

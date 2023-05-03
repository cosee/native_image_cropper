import 'dart:math';

import 'package:flutter/rendering.dart';

part 'aspect_ratio_greater_equals_one.dart';
part 'aspect_ratio_not_null.dart';
part 'aspect_ratio_null.dart';
part 'aspect_ratio_smaller_one.dart';

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

  /// Computes the aspect ratio delta for a left diagonal movement.
  /// To be precise a top left or bottom right movement.
  Offset _computeAspectRatioDeltaLeftDiagonal(Offset delta);

  /// Computes the aspect ratio delta for a right diagonal movement.
  /// To be precise a top right or bottom left movement.
  Offset _computeAspectRatioDeltaRightDiagonal(Offset delta);

  /// Returns a new crop [Rect] from an [oldCropRect] after applying
  /// the aspect ratio if given.
  Rect? computeCropRectWithNewAspectRatio({
    Rect? oldCropRect,
    Rect? imageRect,
  });

  /// Computes a new [cropRect] that corresponds to the same region of
  /// an [oldImageRect] after it has been resized to fit within the [imageRect].
  Rect computeCropRectForResizedImageRect({
    required Rect imageRect,
    required Rect oldImageRect,
    required Rect cropRect,
  }) {
    final scale = imageRect.width / oldImageRect.width;
    return cropRect * scale;
  }

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

    final newDelta =
        _smoothDelta(cropRect: cropRect, imageRect: imageRect, delta: delta);
    final newCropRect = cropRect.shift(newDelta);
    return _constraintCropRect(
      newCropRect: newCropRect,
      cropRect: cropRect,
      imageRect: imageRect,
    );
  }

  /// Smooths the given [delta] by setting dx or dy to zero if the [cropRect]
  /// is close to the boundaries of [imageRect] considering a [_tolerance].
  Offset _smoothDelta({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    double dx = delta.dx;
    double dy = delta.dy;

    if (cropRect.top < _tolerance && delta.dy < 0) {
      dy = 0;
    } else if (cropRect.bottom > imageRect.height - _tolerance &&
        delta.dy > 0) {
      dy = 0;
    } else if (cropRect.left < _tolerance && delta.dx < 0) {
      dx = 0;
    } else if (cropRect.right > imageRect.right - _tolerance && delta.dx > 0) {
      dx = 0;
    }
    return Offset(dx, dy);
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

    Offset newDelta = _smoothTopDelta(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: delta,
    );
    newDelta = _smoothLeftDelta(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: newDelta,
    );

    final deltaWithAspectRatio = _computeAspectRatioDeltaLeftDiagonal(newDelta);
    final newCropRect = Rect.fromPoints(
      cropRect.topLeft + deltaWithAspectRatio,
      cropRect.bottomRight,
    );

    if (imageRect.doesNotContain(newCropRect) ||
        _isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }

    return newCropRect;
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

    Offset newDelta = _smoothTopDelta(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: delta,
    );
    newDelta = _smoothRightDelta(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: newDelta,
    );

    final deltaWithAspectRatio =
        _computeAspectRatioDeltaRightDiagonal(newDelta);
    final newCropRect = Rect.fromPoints(
      cropRect.topLeft + Offset(0, deltaWithAspectRatio.dy),
      cropRect.bottomRight + Offset(deltaWithAspectRatio.dx, 0),
    );

    if (imageRect.doesNotContain(newCropRect) ||
        _isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }

    return newCropRect;
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

    Offset newDelta = _smoothBottom(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: delta,
    );
    newDelta = _smoothLeftDelta(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: newDelta,
    );

    final deltaWithAspectRatio =
        _computeAspectRatioDeltaRightDiagonal(newDelta);
    final newCropRect = Rect.fromPoints(
      cropRect.topLeft + Offset(deltaWithAspectRatio.dx, 0),
      cropRect.bottomRight + Offset(0, deltaWithAspectRatio.dy),
    );

    if (imageRect.doesNotContain(newCropRect) ||
        _isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }

    return newCropRect;
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

    Offset newDelta = _smoothBottom(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: delta,
    );
    newDelta = _smoothRightDelta(
      cropRect: cropRect,
      imageRect: imageRect,
      delta: newDelta,
    );

    final deltaWithAspectRatio = _computeAspectRatioDeltaLeftDiagonal(newDelta);
    final newCropRect = Rect.fromPoints(
      cropRect.topLeft,
      cropRect.bottomRight + deltaWithAspectRatio,
    );

    if (imageRect.doesNotContain(newCropRect) ||
        _isSmallerThanMinCropRect(newCropRect)) {
      return cropRect;
    }

    return newCropRect;
  }

  /// Smooths the top movement if we are close to the top boundaries of
  /// [imageRect] considering a [_tolerance].
  Offset _smoothTopDelta({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    double dy = delta.dy;
    if (cropRect.top < _tolerance && delta.dy < 0) {
      dy = 0;
    }
    return delta.copyWith(dy: dy);
  }

  /// Smooths the bottom movement if we are close to the top boundaries of
  /// [imageRect] considering a [_tolerance].
  Offset _smoothBottom({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    double dy = delta.dy;
    if (cropRect.bottom > imageRect.height - _tolerance && delta.dy > 0) {
      dy = 0;
    }
    return delta.copyWith(dy: dy);
  }

  /// Smooths the left movement if we are close to the top boundaries of
  /// [imageRect] considering a [_tolerance].
  Offset _smoothLeftDelta({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    double dx = delta.dx;
    if (cropRect.left < _tolerance && delta.dx < 0) {
      dx = 0;
    }
    return delta.copyWith(dx: dx);
  }

  /// Smooths the right movement if we are close to the top boundaries of
  /// [imageRect] considering a [_tolerance].
  Offset _smoothRightDelta({
    required Rect cropRect,
    required Rect imageRect,
    required Offset delta,
  }) {
    double dx = delta.dx;
    if (cropRect.right > imageRect.right - _tolerance && delta.dx > 0) {
      dx = 0;
    }
    return delta.copyWith(dx: dx);
  }

  /// Checks if the width or height of the [rect] is less
  /// than [minCropRectSize].
  bool _isSmallerThanMinCropRect(Rect rect) =>
      rect.width < minCropRectSize || rect.height < minCropRectSize;
}

extension on Offset {
  /// Creates a copy of this [Offset] with the given fields
  /// replaced by the non-null parameter values.
  Offset copyWith({
    double? dx,
    double? dy,
  }) =>
      Offset(dx ?? this.dx, dy ?? this.dy);
}

extension on Rect {
  /// Indicating of this [Rect] does not contain [other].
  bool doesNotContain(Rect other) =>
      other.top < top ||
      other.bottom > bottom ||
      other.left < left ||
      other.right > right;

  Rect operator *(double value) =>
      Rect.fromLTRB(left * value, top * value, right * value, bottom * value);
}

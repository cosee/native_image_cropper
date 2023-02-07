part of 'crop.dart';

/// The [CropUtilsAspectRatioNotNull] class is an interface for performing crop
/// operations on an image with an [aspectRatio].
///
/// Classes that are designed for crop utility with an [aspectRatio] should
/// inherit from this class.
abstract class CropUtilsAspectRatioNotNull extends CropUtils {
  /// Constructs a [CropUtilsAspectRatioNotNull].
  const CropUtilsAspectRatioNotNull({
    required super.minCropRectSize,
    required this.aspectRatio,
  });

  /// The aspect ratio of the cropped image.
  final double aspectRatio;

  /// Computes the aspect ratio delta for a horizontal movement.
  Offset _computeAspectRatioDeltaHorizontal(Offset delta) =>
      Offset(delta.dx, delta.dx.abs() / aspectRatio);

  /// Computes the aspect ratio delta for a vertical movement.
  Offset _computeAspectRatioOffsetVertical(Offset delta) =>
      Offset(delta.dy.abs() * aspectRatio, delta.dy);

  @override
  Offset _computeAspectRatioDeltaLeftDiagonal(Offset delta) {
    if (delta.isXAbsoluteGreaterThanY) {
      if (delta.dx.isNegative) {
        return _computeAspectRatioDeltaHorizontal(delta).setSigns(ySign: -1);
      } else {
        return _computeAspectRatioDeltaHorizontal(delta).setSigns(ySign: 1);
      }
    } else {
      if (delta.dy.isNegative) {
        return _computeAspectRatioOffsetVertical(delta).setSigns(xSign: -1);
      } else {
        return _computeAspectRatioOffsetVertical(delta).setSigns(xSign: 1);
      }
    }
  }

  @override
  Offset _computeAspectRatioDeltaRightDiagonal(Offset delta) {
    if (delta.isXAbsoluteGreaterThanY) {
      if (delta.dx.isNegative) {
        return _computeAspectRatioDeltaHorizontal(delta).setSigns(ySign: 1);
      } else {
        return _computeAspectRatioDeltaHorizontal(delta).setSigns(ySign: -1);
      }
    } else {
      if (delta.dy.isNegative) {
        return _computeAspectRatioOffsetVertical(delta).setSigns(xSign: 1);
      } else {
        return _computeAspectRatioOffsetVertical(delta).setSigns(xSign: -1);
      }
    }
  }
}

extension on Offset {
  /// Indicates whether the absolute value of [dx] is greater than the
  /// absolute value of [dy].
  bool get isXAbsoluteGreaterThanY => dx.abs() > dy.abs();

  /// Sets the signs of [dx] or [dy].
  Offset setSigns({int? xSign, int? ySign}) {
    final validXSign = xSign == null || xSign == 1 || xSign == -1;
    final validYSign = ySign == null || ySign == 1 || ySign == -1;
    assert(
      validXSign && validYSign,
      'xSign and ySign can only be either  null, 1 or -1!',
    );

    double dx = this.dx;
    if (xSign != null) {
      dx = dx.abs() * xSign;
    }
    double dy = this.dy;
    if (ySign != null) {
      dy = dy.abs() * ySign;
    }
    return Offset(dx, dy);
  }
}

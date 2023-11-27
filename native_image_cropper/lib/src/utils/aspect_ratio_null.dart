part of 'crop.dart';

/// The implementation of [CropUtils] with no aspect ratio constraint.
final class CropUtilsAspectRatioNull extends CropUtils {
  /// Constructs a [CropUtilsAspectRatioNull].
  const CropUtilsAspectRatioNull({required super.minCropRectSize});

  @override
  Rect? getInitialRect(Rect? imageRect) => imageRect;

  @override
  Rect? computeCropRectWithNewAspectRatio({
    Rect? oldCropRect,
    Rect? imageRect,
  }) {
    if (oldCropRect == null || imageRect == null) {
      return null;
    }
    return oldCropRect;
  }

  @override
  Offset _computeAspectRatioDeltaRightDiagonal(Offset delta) => delta;

  @override
  Offset _computeAspectRatioDeltaLeftDiagonal(Offset delta) => delta;
}

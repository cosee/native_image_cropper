part of 'crop.dart';

/// The implementation of [CropUtils] with no aspect ratio constraint.
class CropUtilsAspectRatioNull extends CropUtils {
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
  Offset _calculateAspectRatioOffset({
    required Rect oldCropRect,
    required Rect newCropRect,
  }) =>
      Offset(newCropRect.size.width, newCropRect.size.height);
}

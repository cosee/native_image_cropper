part of 'crop.dart';

class CropUtilsAspectRatioNull extends CropUtils {
  const CropUtilsAspectRatioNull({required super.minCropRectSize});

  @override
  Rect? getInitialRect(Rect? imageRect) {
    if (imageRect == null) {
      return null;
    }

    return imageRect;
  }

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
    required Rect cropRect,
    required Rect newRect,
  }) =>
      Offset(newRect.size.width, newRect.size.height);
}

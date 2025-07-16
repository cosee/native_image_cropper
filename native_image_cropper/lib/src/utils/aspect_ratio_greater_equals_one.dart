part of 'crop.dart';

/// The implementation of [CropUtilsAspectRatioNotNull] with an aspect ratio
/// constraint greater than or equals to 1.
final class CropUtilsAspectRatioGreaterEqualsOne
    extends CropUtilsAspectRatioNotNull {
  /// Constructs a [CropUtilsAspectRatioGreaterEqualsOne].
  const CropUtilsAspectRatioGreaterEqualsOne({
    required super.minCropRectSize,
    required super.aspectRatio,
  }) : assert(
         aspectRatio >= 1,
         'Aspect ratio must be greater than or equals to 1!',
       );

  @override
  Rect? getInitialRect(Rect? imageRect) {
    if (imageRect == null) {
      return null;
    }

    final height = min(imageRect.width / aspectRatio, imageRect.height);
    return Rect.fromCenter(
      center: imageRect.center,
      width: height * aspectRatio,
      height: height,
    );
  }

  @override
  Rect? computeCropRectWithNewAspectRatio({
    Rect? oldCropRect,
    Rect? imageRect,
  }) {
    if (oldCropRect == null || imageRect == null) {
      return null;
    }

    final height = min(imageRect.width / aspectRatio, oldCropRect.height);
    final newCropRect = Rect.fromCenter(
      center: oldCropRect.center,
      width: height * aspectRatio,
      height: height,
    );

    double dx = 0;
    if (newCropRect.left < 0) {
      dx = imageRect.left - newCropRect.left;
    } else if (newCropRect.right > imageRect.right) {
      dx = imageRect.right - newCropRect.right;
    }
    return newCropRect.shift(Offset(dx, 0));
  }
}

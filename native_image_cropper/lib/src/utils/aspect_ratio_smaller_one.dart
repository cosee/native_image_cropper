part of 'crop.dart';

/// The implementation of [CropUtilsAspectRatioNotNull] with an aspect ratio
/// constraint smaller than 1.
final class CropUtilsAspectRatioSmallerOne extends CropUtilsAspectRatioNotNull {
  /// Constructs a [CropUtilsAspectRatioSmallerOne].
  const CropUtilsAspectRatioSmallerOne({
    required super.minCropRectSize,
    required super.aspectRatio,
  }) : assert(aspectRatio < 1, 'Aspect ratio must be smaller than 1!');

  @override
  Rect? getInitialRect(Rect? imageRect) {
    if (imageRect == null) {
      return null;
    }

    final width = min(imageRect.width, imageRect.height * aspectRatio);
    return Rect.fromCenter(
      center: imageRect.center,
      width: width,
      height: width / aspectRatio,
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

    final width = min(oldCropRect.width, imageRect.height * aspectRatio);
    final newCropRect = Rect.fromCenter(
      center: oldCropRect.center,
      width: width,
      height: width / aspectRatio,
    );

    double dy = 0;
    if (newCropRect.top < 0) {
      dy = imageRect.top - newCropRect.top;
    } else if (newCropRect.bottom > imageRect.bottom) {
      dy = imageRect.bottom - newCropRect.bottom;
    }
    return newCropRect.shift(Offset(0, dy));
  }
}

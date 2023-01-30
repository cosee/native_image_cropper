part of 'crop.dart';

class CropUtilsAspectRatioSmallerOne extends CropUtils {
  const CropUtilsAspectRatioSmallerOne({
    required super.minCropRectSize,
    required this.aspectRatio,
  }) : assert(aspectRatio < 1, 'Aspect ratio must be smaller than 1!');

  final double aspectRatio;

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
    final newRect = Rect.fromCenter(
      center: oldCropRect.center,
      width: width,
      height: width / aspectRatio,
    );

    double dy = 0;
    if (newRect.top < 0) {
      dy = imageRect.top - newRect.top;
    } else if (newRect.bottom > imageRect.bottom) {
      dy = imageRect.bottom - newRect.bottom;
    }
    return newRect.shift(Offset(0, dy));
  }

  @override
  Offset _calculateAspectRatioOffset({
    required Rect cropRect,
    required Rect newRect,
  }) {
    double width;
    if (newRect.area < cropRect.area) {
      width = max(newRect.width, newRect.height * aspectRatio);
    } else {
      width = min(newRect.width, newRect.height * aspectRatio);
    }
    return Offset(width, width / aspectRatio);
  }
}

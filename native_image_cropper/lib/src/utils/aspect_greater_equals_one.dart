part of 'crop.dart';

class CropUtilsAspectRatioGreaterEqualsOne extends CropUtils {
  const CropUtilsAspectRatioGreaterEqualsOne({
    required super.minCropRectSize,
    required this.aspectRatio,
  }) : assert(
          aspectRatio >= 1,
          'Aspect ratio must be greater than or equals to 1!',
        );

  final double aspectRatio;

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
    final newRect = Rect.fromCenter(
      center: oldCropRect.center,
      width: height * aspectRatio,
      height: height,
    );

    double dx = 0;
    if (newRect.left < 0) {
      dx = imageRect.left - newRect.left;
    } else if (newRect.right > imageRect.right) {
      dx = imageRect.right - newRect.right;
    }
    return newRect.shift(Offset(dx, 0));
  }

  @override
  Offset _calculateAspectRatioOffset({
    required Rect cropRect,
    required Rect newRect,
  }) {
    double height;
    if (newRect.area < cropRect.area) {
      height = max(newRect.width / aspectRatio, newRect.height);
    } else {
      height = min(newRect.width / aspectRatio, newRect.height);
    }
    return Offset(height * aspectRatio, height);
  }
}

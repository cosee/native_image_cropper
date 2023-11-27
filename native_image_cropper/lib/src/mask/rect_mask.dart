part of 'mask.dart';

/// The [RectMask] provides a custom painter to create an rectangle [CropMask].
class RectMask extends CropMask {
  /// Constructs an [RectMask].
  const RectMask({
    required super.rect,
    required super.maskOptions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & size;

    final Path areaPath = Path()..addRect(rect);
    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      areaPath,
    );
    canvas
      ..drawPath(maskPath, backgroundPaint)
      ..drawPath(areaPath, borderPaint);
  }
}

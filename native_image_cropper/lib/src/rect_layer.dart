import 'package:flutter/material.dart';

class CropRectLayer extends CustomPainter {
  const CropRectLayer(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint screenPaint = Paint()..color = Colors.black38;
    final Paint borderPaint = Paint()
      ..color = const Color(0xffCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Rect screenRect = Offset.zero & size;

    final Path areaPath = Path()..addRect(rect);
    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      areaPath,
    );
    canvas
      ..drawPath(maskPath, screenPaint)
      ..drawPath(areaPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

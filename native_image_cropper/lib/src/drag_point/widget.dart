import 'package:flutter/material.dart';

class CropDragPoint extends StatelessWidget {
  const CropDragPoint({
    super.key,
    this.size = 20,
    this.color = Colors.blue,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExtendedPanDetector extends StatelessWidget {
  const ExtendedPanDetector({
    super.key,
    required this.size,
    required this.child,
    required this.onPanUpdate,
  });

  final double size;
  final Widget child;
  final GestureDragUpdateCallback onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      child: Container(
        color: Colors.transparent,
        width: size,
        height: size,
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

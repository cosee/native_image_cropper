import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The ExtendedPanDetector widget enhances the [GestureDetector] by providing
/// an extended hit area for the [onPanUpdate] gesture.
class ExtendedPanDetector extends StatelessWidget {
  /// /// Constructs a ExtendedPanDetector.
  const ExtendedPanDetector({
    required this.size,
    required this.onPanUpdate,
    required this.child,
    super.key,
  });

  /// The size of the extended hit area.
  final double size;

  /// Handles updates during a pan gesture.
  final GestureDragUpdateCallback onPanUpdate;

  /// The widget below this widget in the tree.
  final Widget child;

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('size', size))
      ..add(
        ObjectFlagProperty<GestureDragUpdateCallback>.has(
          'onPanUpdate',
          onPanUpdate,
        ),
      );
  }
}

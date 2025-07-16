import 'dart:math';
import 'dart:ui';

extension DoubleExtension on double {
  double roundTwoPlaces() {
    final mod = pow(10.0, 2);
    return (this * mod).round().toDouble() / mod;
  }
}

extension RectExtension on Rect {
  double get aspectRatio => width / height;

  Rect round() => Rect.fromLTRB(
    left.roundTwoPlaces(),
    top.roundTwoPlaces(),
    right.roundTwoPlaces(),
    bottom.roundTwoPlaces(),
  );
}

extension SizeExtension on Size {
  double get aspectRatio => width / height;
}

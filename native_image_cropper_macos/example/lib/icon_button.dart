import 'package:flutter/cupertino.dart';

class CupertinoIconButton extends StatelessWidget {
  const CupertinoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.shape = BoxShape.rectangle,
  });

  final Icon icon;
  final VoidCallback onPressed;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: shape,
          border: const Border.fromBorderSide(BorderSide()),
        ),
        child: icon,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    super.key,
    required this.onTap,
    this.shape = BoxShape.rectangle,
    required this.icon,
  });

  final VoidCallback onTap;
  final BoxShape shape;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: const Border.fromBorderSide(BorderSide()),
          shape: shape,
        ),
        child: icon,
      ),
    );
  }
}

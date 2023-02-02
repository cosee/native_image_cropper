import 'package:flutter/material.dart';

class AspectRatioDropDownButton extends StatelessWidget {
  const AspectRatioDropDownButton({
    super.key,
    this.aspectRatio,
    required this.onChanged,
  });

  final double? aspectRatio;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<double?>(
      value: aspectRatio,
      items: const [
        DropdownMenuItem(
          child: Text('Custom'),
        ),
        DropdownMenuItem(
          value: 1,
          child: Text('1:1'),
        ),
        DropdownMenuItem(
          value: 4 / 3,
          child: Text('4:3'),
        ),
        DropdownMenuItem(
          value: 16 / 9,
          child: Text('16:9'),
        ),
        DropdownMenuItem(
          value: 3 / 4,
          child: Text('3:4'),
        ),
        DropdownMenuItem(
          value: 9 / 16,
          child: Text('9:16'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

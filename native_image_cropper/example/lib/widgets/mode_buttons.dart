import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/widgets/rounded_icon_button.dart';

class CropModesButtons extends StatefulWidget {
  const CropModesButtons({
    required this.onChanged,
    super.key,
  });

  final ValueChanged<CropMode> onChanged;

  @override
  State<CropModesButtons> createState() => _CropModesButtonsState();
}

class _CropModesButtonsState extends State<CropModesButtons> {
  CropMode _mode = CropMode.rect;

  void _updateCropMode(CropMode mode) {
    widget.onChanged.call(mode);
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RoundedIconButton(
          onTap: () => _updateCropMode(CropMode.rect),
          color: _mode == CropMode.rect ? secondaryColor : null,
          icon: const Icon(
            Icons.crop,
          ),
        ),
        RoundedIconButton(
          shape: BoxShape.circle,
          onTap: () => _updateCropMode(CropMode.oval),
          color: _mode == CropMode.oval ? secondaryColor : null,
          icon: const Icon(
            Icons.crop,
          ),
        ),
      ],
    );
  }
}

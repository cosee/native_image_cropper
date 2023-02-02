import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';

class CropModesButtons extends StatefulWidget {
  const CropModesButtons({super.key, required this.onChanged});

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
        InkWell(
          onTap: () => _updateCropMode(CropMode.rect),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _mode == CropMode.rect ? secondaryColor : null,
              border: const Border.fromBorderSide(BorderSide()),
            ),
            child: const Icon(
              Icons.crop,
            ),
          ),
        ),
        InkWell(
          onTap: () => _updateCropMode(CropMode.oval),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mode == CropMode.oval ? secondaryColor : null,
              border: const Border.fromBorderSide(
                BorderSide(),
              ),
            ),
            child: const Icon(
              Icons.crop,
            ),
          ),
        ),
      ],
    );
  }
}

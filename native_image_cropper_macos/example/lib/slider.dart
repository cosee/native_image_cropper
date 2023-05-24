import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_image_cropper_macos/native_image_cropper_macos.dart';
import 'package:native_image_cropper_macos_example/themes.dart';

class ImageFormatSlider extends StatefulWidget {
  const ImageFormatSlider({
    required this.onValueChanged,
    super.key,
  });

  final ValueChanged<ImageFormat> onValueChanged;

  @override
  State<ImageFormatSlider> createState() => _ImageFormatSliderState();
}

class _ImageFormatSliderState extends State<ImageFormatSlider> {
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: Colors.transparent,
      border: const Border(),
      middle: CupertinoSlidingSegmentedControl<ImageFormat>(
        backgroundColor: CupertinoColors.systemGrey3,
        groupValue: _format,
        thumbColor: CustomThemes.yellow,
        children: const {
          ImageFormat.jpg: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'JPG',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          ImageFormat.png: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'PNG',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            widget.onValueChanged.call(value);
            setState(() => _format = value);
          }
        },
      ),
    );
  }
}

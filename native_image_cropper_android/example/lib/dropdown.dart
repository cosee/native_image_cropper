import 'package:flutter/material.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';

class ImageFormatDropDown extends StatefulWidget {
  const ImageFormatDropDown({super.key, required this.onChanged});

  final ValueChanged<ImageFormat> onChanged;

  @override
  State<ImageFormatDropDown> createState() => _ImageFormatDropDownState();
}

class _ImageFormatDropDownState extends State<ImageFormatDropDown> {
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ImageFormat>(
      value: _format,
      items: const [
        DropdownMenuItem(
          value: ImageFormat.jpg,
          child: Text('JPG'),
        ),
        DropdownMenuItem(
          value: ImageFormat.png,
          child: Text('PNG'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          widget.onChanged.call(value);
          setState(() => _format = value);
        }
      },
    );
  }
}

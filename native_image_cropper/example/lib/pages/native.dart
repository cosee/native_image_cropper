import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/pages/result.dart';
import 'package:native_image_cropper_example/widgets/image_format_dropdown.dart';

class NativePage extends StatefulWidget {
  const NativePage({
    required this.bytes,
    super.key,
  });

  final Uint8List bytes;

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    final image = Image(
      image: MemoryImage(widget.bytes),
    );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          switch (Platform.operatingSystem) {
            'macos' => Expanded(
                child: image,
              ),
            _ => image,
          },
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ImageFormatDropdown(
                onChanged: (value) => _format = value,
              ),
              InkWell(
                onTap: () => unawaited(_cropImage(context, CropMode.rect)),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    border: Border.fromBorderSide(BorderSide()),
                  ),
                  child: const Icon(
                    Icons.crop,
                  ),
                ),
              ),
              InkWell(
                onTap: () => unawaited(_cropImage(context, CropMode.oval)),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(),
                    ),
                  ),
                  child: const Icon(
                    Icons.crop,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _cropImage(BuildContext context, CropMode mode) async {
    final croppedBytes = await switch (mode) {
      CropMode.rect => NativeImageCropper.cropRect(
          bytes: widget.bytes,
          x: 1200,
          y: 900,
          width: 600,
          height: 600,
          format: _format,
        ),
      CropMode.oval => NativeImageCropper.cropOval(
          bytes: widget.bytes,
          x: 1200,
          y: 900,
          width: 600,
          height: 600,
          format: _format,
        ),
    };

    if (context.mounted) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<ResultPage>(
          builder: (_) => ResultPage(
            bytes: croppedBytes,
            format: _format,
          ),
        ),
      );
    }
  }
}

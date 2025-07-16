import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/pages/result.dart';
import 'package:native_image_cropper_example/widgets/aspect_ratio_dropdown.dart';
import 'package:native_image_cropper_example/widgets/image_format_dropdown.dart';
import 'package:native_image_cropper_example/widgets/mode_buttons.dart';

class DefaultPage extends StatefulWidget {
  const DefaultPage({
    required this.bytes,
    super.key,
  });

  final Uint8List bytes;

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  late CropController _controller;
  CropMode _mode = CropMode.rect;
  double? _aspectRatio;
  ImageFormat _format = ImageFormat.jpg;

  @override
  void initState() {
    super.initState();
    _controller = CropController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final cropPreview = CropPreview(
      controller: _controller,
      bytes: widget.bytes,
      mode: _mode,
      maskOptions: MaskOptions(aspectRatio: _aspectRatio),
      dragPointBuilder: (size, position) => CropDragPoint(
        size: size,
        color: secondaryColor,
      ),
    );
    return Column(
      children: [
        switch (Platform.operatingSystem) {
          'macos' => Expanded(
            child: cropPreview,
          ),
          _ => cropPreview,
        },
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: ImageFormatDropdown(
                onChanged: (value) => _format = value,
              ),
            ),
            Flexible(
              child: AspectRatioDropdown(
                aspectRatio: _aspectRatio,
                onChanged: (value) => setState(() => _aspectRatio = value),
              ),
            ),
            Flexible(
              child: CropModesButtons(
                onChanged: (value) => setState(() => _mode = value),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => unawaited(_cropImage(context)),
              child: const Text('CROP'),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _cropImage(BuildContext context) async {
    final croppedBytes = await _controller.crop(format: _format);
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

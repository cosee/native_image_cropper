import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/pages/result.dart';
import 'package:native_image_cropper_example/widgets/drop_down_button.dart';
import 'package:native_image_cropper_example/widgets/mode_buttons.dart';

class DefaultPage extends StatefulWidget {
  const DefaultPage({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<DefaultPage> createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  late CropController _controller;
  CropMode _mode = CropMode.rect;
  double? _aspectRatio;

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CropPreview(
            controller: _controller,
            bytes: widget.bytes,
            mode: _mode,
            maskOptions: MaskOptions(aspectRatio: _aspectRatio),
            dragPointBuilder: (size, position) => CropDragPoint(
              size: size,
              color: secondaryColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: AspectRatioDropDownButton(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _cropImage(context),
              child: const Text('CROP'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cropImage(BuildContext context) async {
    final croppedBytes = await _controller.crop();
    if (mounted) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<ResultPage>(
          builder: (_) => ResultPage(bytes: croppedBytes),
        ),
      );
    }
  }
}

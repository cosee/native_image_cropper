import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/pages/result.dart';
import 'package:native_image_cropper_example/widgets/aspect_ratio_dropdown.dart';
import 'package:native_image_cropper_example/widgets/image_format_dropdown.dart';
import 'package:native_image_cropper_example/widgets/loading_indicator.dart';
import 'package:native_image_cropper_example/widgets/mode_buttons.dart';

class CustomPage extends StatefulWidget {
  const CustomPage({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CropPreview(
            controller: _controller,
            bytes: widget.bytes,
            mode: _mode,
            hitSize: 30,
            loadingWidget: const LoadingIndicator(),
            maskOptions: MaskOptions(
              aspectRatio: _aspectRatio,
              backgroundColor: Colors.black,
              borderColor: Theme.of(context).colorScheme.primary,
              minSize: 100,
              strokeWidth: 3,
            ),
            dragPointBuilder: _buildCropDragPoints,
          ),
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
    final croppedBytes = await _controller.crop(format: _format);
    if (mounted) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<ResultPage>(
          builder: (_) => ResultPage(bytes: croppedBytes, format: _format),
        ),
      );
    }
  }

  CustomPaint _buildCropDragPoints(
    double size,
    CropDragPointPosition position,
  ) {
    List<Offset> points;
    switch (position) {
      case CropDragPointPosition.topLeft:
        points = [
          Offset(0, size),
          Offset.zero,
          Offset(size, 0),
        ];
        break;
      case CropDragPointPosition.topRight:
        points = [
          Offset(-size, 0),
          Offset.zero,
          Offset(0, size),
        ];
        break;
      case CropDragPointPosition.bottomLeft:
        points = [
          Offset(0, -size),
          Offset.zero,
          Offset(size, 0),
        ];
        break;
      case CropDragPointPosition.bottomRight:
        points = [
          Offset(0, -size),
          Offset.zero,
          Offset(-size, 0),
        ];
        break;
    }

    return CustomPaint(
      foregroundPainter: _CropDragPointPainter(
        points: points,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

class _CropDragPointPainter extends CustomPainter {
  const _CropDragPointPainter({
    required this.points,
    required this.color,
  });

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

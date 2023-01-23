import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/crop_layer.dart';
import 'package:native_image_cropper/src/drag_point.dart';
import 'package:native_image_cropper/src/utils.dart';

class CropPreview extends StatefulWidget {
  const CropPreview({
    super.key,
    this.controller,
    required this.bytes,
  });

  final CropController? controller;
  final Uint8List bytes;

  @override
  State<CropPreview> createState() => _CropPreviewState();
}

class _CropPreviewState extends State<CropPreview> {
  late MemoryImage _image;
  late ImageStream _imageStream;
  ImageInfo? _imageInfo;
  Rect? _cropRect;
  Rect? _imageRect;
  late ImageStreamListener _listener;
  static const double dotSize = 20;

  @override
  void initState() {
    super.initState();
    widget.controller?.updateValue(bytes: widget.bytes);
    _image = MemoryImage(widget.bytes);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupImageStream();
  }

  void _setupImageStream() {
    _imageStream = _image.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener(_loadImageInfo);
    _imageStream.addListener(_listener);
  }

  void _loadImageInfo(ImageInfo info, _) {
    setState(() => _imageInfo = info);
    final image = info.image;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    widget.controller?.updateValue(imageSize: imageSize);
  }

  @override
  void dispose() {
    _imageStream.removeListener(_listener);
    super.dispose();
  }

  bool isMovingCropLayer = false;

  void _onMoveCropRectUpdate(DragUpdateDetails details) {
    if (!isMovingCropLayer) {
      return;
    }

    setState(
      () => _cropRect = CropUtils.moveCropRect(
        delta: details.delta,
        cropRect: _cropRect,
        imageRect: _imageRect,
      ),
    );

    widget.controller?.updateValue(cropRect: _cropRect);
  }

  void _onMoveCropCorner({
    required Offset delta,
    required Rect? Function({
      Rect? cropRect,
      Rect? imageRect,
      required Offset delta,
    })
        moveSpecificCropCornerFnc,
  }) {
    setState(
      () => _cropRect = moveSpecificCropCornerFnc(
        cropRect: _cropRect,
        imageRect: _imageRect,
        delta: delta,
      ),
    );
    widget.controller?.updateValue(cropRect: _cropRect);
  }

  @override
  Widget build(BuildContext context) {
    final imageInfo = _imageInfo;
    if (imageInfo == null) {
      return const SizedBox.shrink();
    } else {
      final cropRect = _cropRect;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(dotSize / 2),
              child: GestureDetector(
                onPanStart: (details) => isMovingCropLayer =
                    _cropRect?.contains(details.localPosition) ?? false,
                onPanUpdate: _onMoveCropRectUpdate,
                onPanEnd: (_) => isMovingCropLayer = false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final image = imageInfo.image;
                    final availableSpace = Offset.zero &
                        Size(constraints.maxWidth, constraints.maxHeight);
                    _imageRect = CropUtils.computeImageRect(
                      Size(
                        image.width.toDouble(),
                        image.height.toDouble(),
                      ),
                      availableSpace,
                    );
                    widget.controller?.updateValue(imageRect: _imageRect);

                    if (cropRect == null) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          setState(() => _cropRect = _imageRect);
                          widget.controller?.updateValue(cropRect: _cropRect);
                        },
                      );
                      return const SizedBox.shrink();
                    }

                    return CustomPaint(
                      foregroundPainter: CropLayer(cropRect),
                      willChange: true,
                      child: Image(
                        image: _image,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (cropRect != null) ...[
              Positioned(
                left: cropRect.left,
                top: cropRect.top,
                child: GestureDetector(
                  onPanUpdate: (details) => _onMoveCropCorner(
                    delta: details.delta,
                    moveSpecificCropCornerFnc: CropUtils.moveTopLeftCorner,
                  ),
                  child: const CropDragPoint(),
                ),
              ),
              Positioned(
                left: cropRect.right,
                top: cropRect.top,
                child: GestureDetector(
                  onPanUpdate: (details) => _onMoveCropCorner(
                    delta: details.delta,
                    moveSpecificCropCornerFnc: CropUtils.moveTopRightCorner,
                  ),
                  child: const CropDragPoint(),
                ),
              ),
              Positioned(
                left: cropRect.left,
                top: cropRect.bottom,
                child: GestureDetector(
                  onPanUpdate: (details) => _onMoveCropCorner(
                    delta: details.delta,
                    moveSpecificCropCornerFnc: CropUtils.moveBottomLeftCorner,
                  ),
                  child: const CropDragPoint(),
                ),
              ),
              Positioned(
                left: cropRect.right,
                top: cropRect.bottom,
                child: GestureDetector(
                  onPanUpdate: (details) => _onMoveCropCorner(
                    delta: details.delta,
                    moveSpecificCropCornerFnc: CropUtils.moveBottomRightCorner,
                  ),
                  child: const CropDragPoint(),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }
}

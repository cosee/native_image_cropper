import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/drag_point.dart';
import 'package:native_image_cropper/src/utils.dart';

class CropPreview extends StatefulWidget {
  const CropPreview({
    super.key,
    this.controller,
    required this.bytes,
    this.mode = CropMode.rect,
    this.dragPointSize = 20,
    this.layerOptions = const CropLayerOptions(),
  });

  final CropController? controller;
  final Uint8List bytes;
  final CropMode mode;
  final double dragPointSize;
  final CropLayerOptions layerOptions;

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

  CropController? get _controller => widget.controller;

  double get _dragPointSize => widget.dragPointSize;

  CropLayerOptions get layerOptions => widget.layerOptions;

  @override
  void initState() {
    super.initState();
    _controller?.updateValue(bytes: widget.bytes, mode: widget.mode);
    _image = MemoryImage(widget.bytes);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupImageStream();
  }

  @override
  void didUpdateWidget(covariant CropPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _controller?.updateValue(mode: widget.mode);
    }
  }

  @override
  void dispose() {
    _imageStream.removeListener(_listener);
    super.dispose();
  }

  bool isMovingCropLayer = false;

  @override
  Widget build(BuildContext context) {
    final imageInfo = _imageInfo;
    if (imageInfo == null) {
      return const SizedBox.shrink();
    } else {
      final cropRect = _cropRect;
      return Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(_dragPointSize / 2),
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
                    imageSize: Size(
                      image.width.toDouble(),
                      image.height.toDouble(),
                    ),
                    availableSpace: availableSpace,
                  );
                  _controller?.updateValue(imageRect: _imageRect);

                  if (cropRect == null) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                        setState(() => _cropRect = _imageRect);
                        _controller?.updateValue(cropRect: _cropRect);
                      },
                    );
                    return const SizedBox.shrink();
                  }

                  return CustomPaint(
                    foregroundPainter: widget.mode == CropMode.oval
                        ? CropOvalLayer(
                            rect: cropRect,
                            layerOptions: layerOptions,
                          )
                        : CropRectLayer(
                            rect: cropRect,
                            layerOptions: layerOptions,
                          ),
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
                child: CropDragPoint(size: _dragPointSize),
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
                child: CropDragPoint(size: _dragPointSize),
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
                child: CropDragPoint(size: _dragPointSize),
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
                child: CropDragPoint(size: _dragPointSize),
              ),
            ),
          ],
        ],
      );
    }
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
    _controller?.updateValue(imageSize: imageSize);
  }

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

    _controller?.updateValue(cropRect: _cropRect);
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
    _controller?.updateValue(cropRect: _cropRect);
  }
}

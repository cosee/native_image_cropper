import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/extended_pan_detector.dart';
import 'package:native_image_cropper/src/utils.dart';

typedef CropDragPointBuilder = Widget Function(
  double size,
  CropDragPointPosition position,
);

class CropPreview extends StatefulWidget {
  const CropPreview({
    super.key,
    this.controller,
    required this.bytes,
    this.mode = CropMode.rect,
    this.dragPointSize = 20,
    this.layerOptions = const CropLayerOptions(),
    this.dragPointBuilder,
    this.loadingWidget,
    this.hitSize = 20,
  });

  final CropController? controller;
  final Uint8List bytes;
  final CropMode mode;
  final double dragPointSize;
  final CropLayerOptions layerOptions;
  final CropDragPointBuilder? dragPointBuilder;
  final Widget? loadingWidget;
  final double hitSize;

  @override
  State<CropPreview> createState() => _CropPreviewState();
}

class _CropPreviewState extends State<CropPreview> {
  late MemoryImage _image;
  late ImageStream _imageStream;
  late ImageStreamListener _listener;
  late CropUtils _cropUtils;
  ImageInfo? _imageInfo;
  Rect? _cropRect;
  Rect? _imageRect;

  double get _hitAreaSize => widget.dragPointSize + widget.hitSize;

  @override
  void initState() {
    super.initState();
    widget.controller?.updateValue(bytes: widget.bytes, mode: widget.mode);
    _image = MemoryImage(widget.bytes);
    _cropUtils = CropUtils(_hitAreaSize);
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
      widget.controller?.updateValue(mode: widget.mode);
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
    final loadingWidget = widget.loadingWidget ?? const SizedBox.shrink();
    final imageInfo = _imageInfo;
    if (imageInfo == null) {
      return loadingWidget;
    } else {
      final cropRect = _cropRect;
      return Stack(
        children: [
          Padding(
            padding:
                EdgeInsets.all(widget.dragPointSize / 2 + widget.hitSize / 2),
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
                  _imageRect = _cropUtils.computeImageRect(
                    imageSize: Size(
                      image.width.toDouble(),
                      image.height.toDouble(),
                    ),
                    availableSpace: availableSpace,
                  );
                  widget.controller?.updateValue(imageRect: _imageRect);

                  if (cropRect == null) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                        setState(() => _cropRect = _imageRect);
                        widget.controller?.updateValue(cropRect: _cropRect);
                      },
                    );
                    return loadingWidget;
                  }

                  return CustomPaint(
                    foregroundPainter: widget.mode == CropMode.oval
                        ? CropOvalLayer(
                            rect: cropRect,
                            layerOptions: widget.layerOptions,
                          )
                        : CropRectLayer(
                            rect: cropRect,
                            layerOptions: widget.layerOptions,
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
              child: ExtendedPanDetector(
                size: _hitAreaSize,
                onPanUpdate: (details) => _onMoveCropCorner(
                  delta: details.delta,
                  moveSpecificCropCornerFnc: _cropUtils.moveTopLeftCorner,
                ),
                child: widget.dragPointBuilder?.call(
                      widget.dragPointSize,
                      CropDragPointPosition.topLeft,
                    ) ??
                    CropDragPoint(size: widget.dragPointSize),
              ),
            ),
            Positioned(
              left: cropRect.right,
              top: cropRect.top,
              child: ExtendedPanDetector(
                size: _hitAreaSize,
                onPanUpdate: (details) => _onMoveCropCorner(
                  delta: details.delta,
                  moveSpecificCropCornerFnc: _cropUtils.moveTopRightCorner,
                ),
                child: widget.dragPointBuilder?.call(
                      widget.dragPointSize,
                      CropDragPointPosition.topRight,
                    ) ??
                    CropDragPoint(size: widget.dragPointSize),
              ),
            ),
            Positioned(
              left: cropRect.left,
              top: cropRect.bottom,
              child: ExtendedPanDetector(
                size: _hitAreaSize,
                onPanUpdate: (details) => _onMoveCropCorner(
                  delta: details.delta,
                  moveSpecificCropCornerFnc: _cropUtils.moveBottomLeftCorner,
                ),
                child: widget.dragPointBuilder?.call(
                      widget.dragPointSize,
                      CropDragPointPosition.bottomLeft,
                    ) ??
                    CropDragPoint(size: widget.dragPointSize),
              ),
            ),
            Positioned(
              left: cropRect.right,
              top: cropRect.bottom,
              child: ExtendedPanDetector(
                size: _hitAreaSize,
                onPanUpdate: (details) => _onMoveCropCorner(
                  delta: details.delta,
                  moveSpecificCropCornerFnc: _cropUtils.moveBottomRightCorner,
                ),
                child: widget.dragPointBuilder?.call(
                      widget.dragPointSize,
                      CropDragPointPosition.bottomRight,
                    ) ??
                    CropDragPoint(size: widget.dragPointSize),
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
    widget.controller?.updateValue(imageSize: imageSize);
  }

  void _onMoveCropRectUpdate(DragUpdateDetails details) {
    if (!isMovingCropLayer) {
      return;
    }

    setState(
      () => _cropRect = _cropUtils.moveCropRect(
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
}

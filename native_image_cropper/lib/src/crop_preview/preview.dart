import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/crop_preview/drag_points.dart';
import 'package:native_image_cropper/src/crop_preview/image.dart';
import 'package:native_image_cropper/src/drag_point/enum.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

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
  late CropController _controller;

  double get _hitAreaSize => widget.dragPointSize + widget.hitSize;

  double get _minCropRectSize => max(_hitAreaSize, widget.layerOptions.minSize);

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? CropController())
      ..mode = widget.mode
      ..bytes = widget.bytes;
    _image = MemoryImage(widget.bytes);
    _cropUtils =
        _getCropUtilsDependingOnAspectRatio(widget.layerOptions.aspectRatio);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupImageStream();
  }

  @override
  void didUpdateWidget(covariant CropPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.bytes.length != oldWidget.bytes.length) {
      _image = MemoryImage(widget.bytes);
      _controller
        ..bytes = widget.bytes
        ..imageSize = null
        ..cropRect = null;
      _imageStream.removeListener(_listener);
      _setupImageStream();
    } else {
      if (widget.mode != oldWidget.mode) {
        _controller.modeNotifier.value = widget.mode;
      }
      final aspectRatio = widget.layerOptions.aspectRatio;
      if (aspectRatio != oldWidget.layerOptions.aspectRatio) {
        _cropUtils = _getCropUtilsDependingOnAspectRatio(aspectRatio);
        _controller.cropRect = _cropUtils.computeCropRectWithNewAspectRatio(
          oldCropRect: _controller.cropRect,
          imageRect: _controller.imageRect,
        );
      }
    }
  }

  @override
  void dispose() {
    _imageStream.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool isMovingCropLayer = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CropImage(
            dragPointSize: widget.dragPointSize,
            hitSize: widget.hitSize,
            controller: _controller,
            loadingWidget: widget.loadingWidget,
            cropUtils: _cropUtils,
            layerOptions: widget.layerOptions,
            image: _image,
          ),
          CropDragPoints(
            dragPointBuilder: widget.dragPointBuilder,
            controller: _controller,
            cropUtils: _cropUtils,
            dragPointSize: widget.dragPointSize,
            hitSize: widget.hitSize,
          ),
        ],
      ),
    );
  }

  void _setupImageStream() {
    _imageStream = _image.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener(_loadImageInfo);
    _imageStream.addListener(_listener);
  }

  void _loadImageInfo(ImageInfo info, _) {
    final image = info.image;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    _controller.imageSize = imageSize;
  }

  CropUtils _getCropUtilsDependingOnAspectRatio(double? aspectRatio) {
    if (aspectRatio == null) {
      return CropUtilsAspectRatioNull(minCropRectSize: _minCropRectSize);
    } else if (aspectRatio < 1) {
      return CropUtilsAspectRatioSmallerOne(
        minCropRectSize: _minCropRectSize,
        aspectRatio: aspectRatio,
      );
    } else {
      return CropUtilsAspectRatioGreaterEqualsOne(
        minCropRectSize: _minCropRectSize,
        aspectRatio: aspectRatio,
      );
    }
  }
}

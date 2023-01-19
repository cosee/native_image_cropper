import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/crop_layer.dart';
import 'package:native_image_cropper/src/loading_indicator.dart';
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
    _imageInfo = info;
    final image = _imageInfo!.image;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    widget.controller?.updateValue(imageSize: imageSize);
    setState(() {});
  }

  @override
  void dispose() {
    _imageStream.removeListener(_listener);
    super.dispose();
  }

  bool isMovingCropLayer = false;

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return const LoadingIndicator();
    } else {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(dotSize / 2),
                  child: GestureDetector(
                    onPanStart: (details) => isMovingCropLayer =
                        _cropRect!.contains(details.localPosition),
                    onPanUpdate: (details) {
                      if (!isMovingCropLayer) return;

                      Rect newRect = _cropRect!.shift(details.delta);

                      if (newRect.right > _imageRect!.right) {
                        newRect = Rect.fromPoints(
                          _cropRect!.topLeft,
                          Offset(_imageRect!.right, _cropRect!.bottom),
                        );
                      }
                      if (newRect.left < _imageRect!.left) {
                        newRect = Rect.fromPoints(
                          Offset(_imageRect!.left, _cropRect!.top),
                          _cropRect!.bottomRight,
                        );
                      }

                      if (newRect.top < _imageRect!.top) {
                        newRect = Rect.fromPoints(
                          Offset(_cropRect!.left, _imageRect!.top),
                          _cropRect!.bottomRight,
                        );
                      }
                      if (newRect.bottom > _imageRect!.bottom) {
                        newRect = Rect.fromPoints(
                          _cropRect!.topLeft,
                          Offset(_cropRect!.right, _imageRect!.bottom),
                        );
                      }

                      _cropRect = newRect;
                      widget.controller?.updateValue(cropRect: _cropRect);
                      setState(() {});
                    },
                    onPanEnd: (_) => isMovingCropLayer = false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableSpace = Offset.zero &
                            Size(constraints.maxWidth, constraints.maxHeight);
                        _imageRect = CropUtils.computeEffectiveRect(
                          Size(
                            _imageInfo!.image.width.toDouble(),
                            _imageInfo!.image.height.toDouble(),
                          ),
                          availableSpace,
                        );
                        widget.controller?.updateValue(imageRect: _imageRect!);
                        if (_cropRect == null) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (timeStamp) {
                              _cropRect = _imageRect;
                              widget.controller
                                  ?.updateValue(cropRect: _cropRect!);
                              setState(() {});
                            },
                          );
                        }
                        if (_cropRect == null) {
                          return const LoadingIndicator();
                        }

                        return CustomPaint(
                          foregroundPainter: CropLayer(_cropRect!),
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
                Positioned(
                  left: _cropRect?.left,
                  top: _cropRect?.top,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _cropRect = CropUtils.moveTopLeftCorner(
                        cropRect: _cropRect!,
                        imageRect: _imageRect!,
                        delta: details.delta,
                      );
                      widget.controller?.updateValue(cropRect: _cropRect!);
                      setState(() {});
                    },
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _cropRect?.right,
                  top: _cropRect?.top,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _cropRect = CropUtils.moveTopRightCorner(
                        cropRect: _cropRect!,
                        imageRect: _imageRect!,
                        delta: details.delta,
                      );
                      widget.controller?.updateValue(cropRect: _cropRect!);
                      setState(() {});
                    },
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _cropRect?.left,
                  top: _cropRect?.bottom,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _cropRect = CropUtils.moveBottomLeftCorner(
                        cropRect: _cropRect!,
                        imageRect: _imageRect!,
                        delta: details.delta,
                      );
                      widget.controller?.updateValue(cropRect: _cropRect!);
                      setState(() {});
                    },
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _cropRect?.right,
                  top: _cropRect?.bottom,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _cropRect = CropUtils.moveBottomRightCorner(
                        cropRect: _cropRect!,
                        imageRect: _imageRect!,
                        delta: details.delta,
                      );
                      widget.controller?.updateValue(cropRect: _cropRect!);
                      setState(() {});
                    },
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }
}

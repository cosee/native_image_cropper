import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/drag_point/enum.dart';
import 'package:native_image_cropper/src/extended_pan_detector.dart';
import 'package:native_image_cropper/src/mask/oval_layer.dart';
import 'package:native_image_cropper/src/mask/rect_layer.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

part 'drag_points.dart';
part 'image.dart';

/// Type alias for a callback function.
/// Used to build a custom drag point in a [CropPreview].
typedef CropDragPointBuilder = Widget Function(
  double size,
  CropDragPointPosition position,
);

/// The [CropPreview] implements a preview screen for image cropping.
/// It allows the user to crop the image using a movable and resizable
/// rectangle.
class CropPreview extends StatefulWidget {
  /// Constructs a [CropPreview].
  const CropPreview({
    super.key,
    this.controller,
    required this.bytes,
    this.mode = CropMode.rect,
    this.maskOptions = const MaskOptions(),
    this.dragPointSize = 20,
    this.dragPointBuilder,
    this.hitSize = 20,
    this.loadingWidget = const SizedBox.shrink(),
  });

  /// Controls the behaviour of the [CropPreview].
  final CropController? controller;

  /// Represents the image data to be displayed in the [CropPreview].
  final Uint8List bytes;

  /// Determines the type of cropping that will be applied to the image.
  final CropMode mode;

  /// Options to customize the crop mask. Defaults to [MaskOptions]
  final MaskOptions maskOptions;

  /// Determines the size of the drag points. Defaults to 20.
  final double dragPointSize;

  /// Allows customization of the crop drag points. Defaults to [CropDragPoint].
  final CropDragPointBuilder? dragPointBuilder;

  /// The size of the hit area around each drag point where it can be
  /// interacted with. Defaults to 20.
  final double hitSize;

  /// Widget which should be shown while the image is being loaded.
  /// Defaults [SizedBox.shrink].
  final Widget loadingWidget;

  @override
  State<CropPreview> createState() => _CropPreviewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CropController?>('controller', controller))
      ..add(IntProperty('bytes', bytes.lengthInBytes))
      ..add(EnumProperty<CropMode>('mode', mode))
      ..add(DoubleProperty('dragPointSize', dragPointSize))
      ..add(DiagnosticsProperty<MaskOptions>('maskOptions', maskOptions))
      ..add(
        ObjectFlagProperty<CropDragPointBuilder?>.has(
          'dragPointBuilder',
          dragPointBuilder,
        ),
      )
      ..add(DoubleProperty('hitSize', hitSize));
  }
}

class _CropPreviewState extends State<CropPreview> {
  late MemoryImage _image;
  late ImageStream _imageStream;
  late ImageStreamListener _listener;
  late CropUtils _cropUtils;
  late CropController _controller;

  double get _hitAreaSize => widget.dragPointSize + widget.hitSize;

  double get _minCropRectSize => max(_hitAreaSize, widget.maskOptions.minSize);

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? CropController())
      ..mode = widget.mode
      ..bytes = widget.bytes;
    _image = MemoryImage(widget.bytes);
    _cropUtils =
        _getCropUtilsDependingOnAspectRatio(widget.maskOptions.aspectRatio);
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
      final aspectRatio = widget.maskOptions.aspectRatio;
      if (aspectRatio != oldWidget.maskOptions.aspectRatio) {
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          _CropImage(
            dragPointSize: widget.dragPointSize,
            hitSize: widget.hitSize,
            controller: _controller,
            loadingWidget: widget.loadingWidget,
            cropUtils: _cropUtils,
            maskOptions: widget.maskOptions,
            image: _image,
          ),
          _CropDragPoints(
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

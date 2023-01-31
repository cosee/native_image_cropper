import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/mask/oval_layer.dart';
import 'package:native_image_cropper/src/mask/rect_layer.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

/// The [CropImage] represents the image to be cropped with its [CropMask].
class CropImage extends StatefulWidget {
  /// Constructs a [CropImage].
  const CropImage({
    super.key,
    required this.controller,
    required this.image,
    required this.maskOptions,
    required this.dragPointSize,
    required this.hitSize,
    required this.loadingWidget,
    required this.cropUtils,
  });

  /// Controls the behaviour of the [CropPreview].
  final CropController controller;

  /// Displays the image in the [CropPreview].
  final MemoryImage image;

  /// Options to customize the crop mask
  final MaskOptions maskOptions;

  /// Determines the size of the drag points.
  final double dragPointSize;

  /// The size of the hit area around each drag point where it can be
  /// interacted with.
  final double hitSize;

  /// Widget which should be shown while the image is being loaded.
  final Widget loadingWidget;

  /// Helper functions for cropping and resizing an image.
  final CropUtils cropUtils;

  @override
  State<CropImage> createState() => _CropImageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CropController>('controller', controller))
      ..add(DiagnosticsProperty<MemoryImage>('image', image))
      ..add(DiagnosticsProperty<MaskOptions>('maskOptions', maskOptions))
      ..add(DoubleProperty('dragPointSize', dragPointSize))
      ..add(DoubleProperty('hitSize', hitSize))
      ..add(DiagnosticsProperty<CropUtils>('cropUtils', cropUtils));
  }
}

class _CropImageState extends State<CropImage> {
  bool _isMovingCropLayer = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        widget.dragPointSize / 2 + widget.hitSize / 2,
      ),
      child: ValueListenableBuilder(
        valueListenable: widget.controller.imageSizeNotifier,
        builder: (context, imageSize, child) {
          if (imageSize == null) {
            return widget.loadingWidget;
          }
          return GestureDetector(
            onPanStart: (details) => _isMovingCropLayer = widget
                    .controller.cropRectNotifier.value
                    ?.contains(details.localPosition) ??
                false,
            onPanUpdate: _onMoveCropRectUpdate,
            onPanEnd: (_) => _isMovingCropLayer = false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableSpace = Offset.zero &
                    Size(constraints.maxWidth, constraints.maxHeight);
                final imageRect = widget.cropUtils.computeImageRect(
                  imageSize: imageSize,
                  availableSpace: availableSpace,
                );

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    widget.controller.imageRect = imageRect;
                    widget.controller.cropRect ??=
                        widget.cropUtils.getInitialRect(imageRect);
                  },
                );

                return child ?? const SizedBox.shrink();
              },
            ),
          );
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.controller.cropRectNotifier,
            widget.controller.modeNotifier,
          ]),
          builder: (context, child) {
            final cropRect = widget.controller.cropRect;
            if (cropRect == null) {
              return widget.loadingWidget;
            }
            return CustomPaint(
              foregroundPainter: widget.controller.mode == CropMode.oval
                  ? OvalMask(
                      rect: cropRect,
                      maskOptions: widget.maskOptions,
                    )
                  : RectMask(
                      rect: cropRect,
                      maskOptions: widget.maskOptions,
                    ),
              willChange: true,
              child: child,
            );
          },
          child: Image(
            image: widget.image,
          ),
        ),
      ),
    );
  }

  void _onMoveCropRectUpdate(DragUpdateDetails details) {
    if (!_isMovingCropLayer) {
      return;
    }
    final controller = widget.controller;
    controller.cropRect = widget.cropUtils.moveCropRect(
      delta: details.delta,
      cropRect: controller.cropRect,
      imageRect: controller.imageRect,
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/crop_layer/oval_layer.dart';
import 'package:native_image_cropper/src/crop_layer/rect_layer.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

class CropImage extends StatefulWidget {
  const CropImage({
    super.key,
    required this.dragPointSize,
    required this.hitSize,
    required this.controller,
    required this.loadingWidget,
    required this.cropUtils,
    required this.layerOptions,
    required this.image,
  });

  final double dragPointSize;
  final double hitSize;
  final CropController controller;
  final Widget? loadingWidget;
  final CropUtils cropUtils;
  final CropLayerOptions layerOptions;
  final MemoryImage image;

  @override
  State<CropImage> createState() => _CropImageState();
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
            return widget.loadingWidget ?? const SizedBox.shrink();
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
        child: ValueListenableBuilder(
          valueListenable: widget.controller.cropRectNotifier,
          builder: (context, cropRect, child) {
            if (cropRect == null) {
              return widget.loadingWidget ?? const SizedBox.shrink();
            }
            return ValueListenableBuilder(
              valueListenable: widget.controller.modeNotifier,
              builder: (context, mode, child) {
                return CustomPaint(
                  foregroundPainter: mode == CropMode.oval
                      ? CropOvalLayer(
                          rect: cropRect,
                          layerOptions: widget.layerOptions,
                        )
                      : CropRectLayer(
                          rect: cropRect,
                          layerOptions: widget.layerOptions,
                        ),
                  willChange: true,
                  child: child,
                );
              },
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

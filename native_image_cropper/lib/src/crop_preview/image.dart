import 'package:flutter/widgets.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/mask/oval_layer.dart';
import 'package:native_image_cropper/src/mask/rect_layer.dart';
import 'package:native_image_cropper/src/utils/crop.dart';

class CropImage extends StatefulWidget {
  const CropImage({
    super.key,
    required this.dragPointSize,
    required this.hitSize,
    required this.controller,
    required this.loadingWidget,
    required this.cropUtils,
    required this.maskOptions,
    required this.image,
  });

  final double dragPointSize;
  final double hitSize;
  final CropController controller;
  final Widget? loadingWidget;
  final CropUtils cropUtils;
  final MaskOptions maskOptions;
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
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.controller.cropRectNotifier,
            widget.controller.modeNotifier,
          ]),
          builder: (context, child) {
            final cropRect = widget.controller.cropRect;
            if (cropRect == null) {
              return widget.loadingWidget ?? const SizedBox.shrink();
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

import 'package:flutter/widgets.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/drag_point/enum.dart';
import 'package:native_image_cropper/src/extended_pan_detector.dart';
import 'package:native_image_cropper/src/utils.dart';

class CropDragPoints extends StatelessWidget {
  const CropDragPoints({
    super.key,
    required this.controller,
    required this.cropUtils,
    this.dragPointBuilder,
    required this.dragPointSize,
    required this.hitSize,
  });

  final CropDragPointBuilder? dragPointBuilder;
  final CropController controller;
  final CropUtils cropUtils;
  final double dragPointSize;
  final double hitSize;

  @override
  Widget build(BuildContext context) {
    final hitAreaSize = dragPointSize + hitSize;
    return ValueListenableBuilder(
      valueListenable: controller.imageRectNotifier,
      builder: (context, value, child) {
        if (value == null) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder(
          valueListenable: controller.cropRectNotifier,
          builder: (context, cropRect, child) {
            if (cropRect == null) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              width: value.width + hitAreaSize,
              height: value.height + hitAreaSize,
              child: Stack(
                children: [
                  Positioned(
                    top: cropRect.top,
                    left: cropRect.left,
                    child: ExtendedPanDetector(
                      size: hitAreaSize,
                      onPanUpdate: (details) => _onMoveCropCorner(
                        delta: details.delta,
                        moveSpecificCropCornerFnc: cropUtils.moveTopLeftCorner,
                      ),
                      child: dragPointBuilder?.call(
                            dragPointSize,
                            CropDragPointPosition.topLeft,
                          ) ??
                          CropDragPoint(size: dragPointSize),
                    ),
                  ),
                  Positioned(
                    left: cropRect.right,
                    top: cropRect.top,
                    child: ExtendedPanDetector(
                      size: hitAreaSize,
                      onPanUpdate: (details) => _onMoveCropCorner(
                        delta: details.delta,
                        moveSpecificCropCornerFnc: cropUtils.moveTopRightCorner,
                      ),
                      child: dragPointBuilder?.call(
                            dragPointSize,
                            CropDragPointPosition.topRight,
                          ) ??
                          CropDragPoint(size: dragPointSize),
                    ),
                  ),
                  Positioned(
                    left: cropRect.left,
                    top: cropRect.bottom,
                    child: ExtendedPanDetector(
                      size: hitAreaSize,
                      onPanUpdate: (details) => _onMoveCropCorner(
                        delta: details.delta,
                        moveSpecificCropCornerFnc:
                            cropUtils.moveBottomLeftCorner,
                      ),
                      child: dragPointBuilder?.call(
                            dragPointSize,
                            CropDragPointPosition.bottomLeft,
                          ) ??
                          CropDragPoint(size: dragPointSize),
                    ),
                  ),
                  Positioned(
                    left: cropRect.right,
                    top: cropRect.bottom,
                    child: ExtendedPanDetector(
                      size: hitAreaSize,
                      onPanUpdate: (details) => _onMoveCropCorner(
                        delta: details.delta,
                        moveSpecificCropCornerFnc:
                            cropUtils.moveBottomRightCorner,
                      ),
                      child: dragPointBuilder?.call(
                            dragPointSize,
                            CropDragPointPosition.bottomRight,
                          ) ??
                          CropDragPoint(size: dragPointSize),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    controller.cropRect = moveSpecificCropCornerFnc(
      cropRect: controller.cropRect,
      imageRect: controller.imageRectNotifier.value,
      delta: delta,
    );
  }
}

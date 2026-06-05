part of 'preview.dart';

class _CropDragPoints extends StatelessWidget {
  const _CropDragPoints({
    required this.controller,
    required this.dragPointSize,
    required this.hitSize,
    required this.cropUtils,
    this.dragPointBuilder,
  });

  final CropController controller;
  final double dragPointSize;
  final CropDragPointBuilder? dragPointBuilder;
  final double hitSize;
  final CropUtils cropUtils;

  @override
  Widget build(BuildContext context) {
    final hitAreaSize = dragPointSize + hitSize;
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.imageRectNotifier,
        controller.cropRectNotifier,
      ]),
      builder: (context, _) {
        final imageRect = controller.imageRect;
        final cropRect = controller.cropRect;
        if (imageRect == null || cropRect == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: imageRect.width + hitAreaSize,
          height: imageRect.height + hitAreaSize,
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
                    moveSpecificCropCornerFnc: cropUtils.moveBottomLeftCorner,
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
                    moveSpecificCropCornerFnc: cropUtils.moveBottomRightCorner,
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
  }

  void _onMoveCropCorner({
    required Offset delta,
    required Rect? Function({
      required Offset delta,
      Rect? cropRect,
      Rect? imageRect,
    }) moveSpecificCropCornerFnc,
  }) =>
      controller.cropRect = moveSpecificCropCornerFnc(
        cropRect: controller.cropRect,
        imageRect: controller.imageRectNotifier.value,
        delta: delta,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<CropController>('controller', controller))
      ..add(DiagnosticsProperty<CropUtils>('cropUtils', cropUtils))
      ..add(DoubleProperty('dragPointSize', dragPointSize))
      ..add(DoubleProperty('hitSize', hitSize))
      ..add(
        ObjectFlagProperty<CropDragPointBuilder?>.has(
          'dragPointBuilder',
          dragPointBuilder,
        ),
      );
  }
}

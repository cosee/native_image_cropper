part of 'preview.dart';

class _CropImage extends StatefulWidget {
  const _CropImage({
    required this.controller,
    required this.image,
    required this.maskOptions,
    required this.dragPointSize,
    required this.hitSize,
    required this.loadingWidget,
    required this.cropUtils,
  });

  final CropController controller;
  final MemoryImage image;
  final MaskOptions maskOptions;
  final double dragPointSize;
  final double hitSize;
  final Widget loadingWidget;
  final CropUtils cropUtils;

  @override
  State<_CropImage> createState() => _CropImageState();

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

class _CropImageState extends State<_CropImage> {
  bool _isMovingCropLayer = false;

  CropController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        widget.dragPointSize / 2 + widget.hitSize / 2,
      ),
      child: ValueListenableBuilder(
        valueListenable: _controller.imageSizeNotifier,
        builder: (context, imageSize, child) {
          if (imageSize == null) {
            return widget.loadingWidget;
          }
          return GestureDetector(
            onPanStart: (details) => _isMovingCropLayer = _controller
                    .cropRectNotifier.value
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
                    final cropRect = _controller.cropRect;
                    if (cropRect == null) {
                      _controller.cropRect =
                          widget.cropUtils.getInitialRect(imageRect);
                    } else {
                      _controller.cropRect =
                          widget.cropUtils.computeCropRectForResizedImageRect(
                        imageRect: imageRect,
                        oldImageRect: _controller.imageRect!,
                        cropRect: cropRect,
                      );
                    }

                    _controller.imageRect = imageRect;
                  },
                );

                return child ?? const SizedBox.shrink();
              },
            ),
          );
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _controller.cropRectNotifier,
            _controller.modeNotifier,
          ]),
          builder: (context, child) {
            final cropRect = _controller.cropRect;
            if (cropRect == null) {
              return widget.loadingWidget;
            }
            return CustomPaint(
              foregroundPainter: _controller.mode == CropMode.oval
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
    _controller.cropRect = widget.cropUtils.moveCropRect(
      delta: details.delta,
      cropRect: _controller.cropRect,
      imageRect: _controller.imageRect,
    );
  }
}

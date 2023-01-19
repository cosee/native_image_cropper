import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../native_image_cropper.dart';
import 'crop_layer2.dart';

class CropPreview extends StatefulWidget {
  const CropPreview({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<CropPreview> createState() => _CropPreviewState();
}

class _CropPreviewState extends State<CropPreview> {
  late MemoryImage _image;
  ImageInfo? _imageInfo;
  late ImageStream _imageStream;
  Rect? _cropRect;
  Rect? _imageRect;
  static const double dotSize = 20;

  @override
  void initState() {
    super.initState();
    _image = MemoryImage(widget.bytes);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setImageInfo();
  }

  void setImageInfo() async {
    _imageStream = _image.resolve(createLocalImageConfiguration(context));

    final listener = ImageStreamListener((ImageInfo info, _) {
      _imageInfo = info;
      setState(() {});
    });
    _imageStream.addListener(listener);
  }

  static GlobalKey globalKey = GlobalKey();
  bool crop = false;

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return const SizedBox.shrink();
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (_imageInfo == null) return;
              final size = Size(_imageInfo!.image.width.toDouble(),
                  _imageInfo!.image.height.toDouble());
              final x = _cropRect!.left / _imageRect!.width * size.width;
              final y = _cropRect!.top / _imageRect!.height * size.height;
              final width = (_cropRect!.width) / _imageRect!.width * size.width;
              final height =
                  (_cropRect!.height) / _imageRect!.height * size.height;
              dev.log('x: $x, y: $y, w: $width, h: $height');

              final bytes = await NativeImageCropper.cropRect(
                  bytes: widget.bytes,
                  x: x.toInt(),
                  y: y.toInt(),
                  width: width.toInt(),
                  height: height.toInt());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => _Result(bytes: bytes)));
            },
            child: Text('CROP'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(dotSize / 2),
                        child: GestureDetector(
                          onPanStart: (details) {
                            crop = _cropRect!.contains(details.localPosition);
                          },
                          onPanUpdate: (details) {
                            if (!crop) return;
                            var localPosition = details.localPosition;
                            var x = localPosition.dx;

                            if (x < 0) {
                              x = 0;
                            }
                            if (x > _imageRect!.size.width) {
                              x = _imageRect!.size.width;
                            }
                            var y = localPosition.dy;
                            if (y < 0) {
                              y = 0;
                            }
                            if (y > _imageRect!.size.height) {
                              y = _imageRect!.size.height;
                            }

                            Rect newRect = _cropRect!.shift(details.delta);
                            if (newRect.right > _imageRect!.right) {
                              newRect = Rect.fromPoints(_cropRect!.topLeft,
                                  Offset(_imageRect!.right, _cropRect!.bottom));
                            }
                            if (newRect.left < _imageRect!.left) {
                              newRect = Rect.fromPoints(
                                  Offset(_imageRect!.left, _cropRect!.top),
                                  _cropRect!.bottomRight);
                            }

                            if (newRect.top < _imageRect!.top) {
                              newRect = Rect.fromPoints(
                                  Offset(_cropRect!.left, _imageRect!.top),
                                  _cropRect!.bottomRight);
                            }
                            if (newRect.bottom > _imageRect!.bottom) {
                              newRect = Rect.fromPoints(_cropRect!.topLeft,
                                  Offset(_cropRect!.right, _imageRect!.bottom));
                            }

                            _cropRect = newRect;
                            setState(() {});
                          },
                          onPanEnd: (details) {
                            crop = false;
                          },
                          child: LayoutBuilder(builder: (context, constraints) {
                            // dev.log('CONSTRAINTS: $constraints');
                            final availableSpace = Offset.zero &
                                Size(constraints.maxWidth,
                                    constraints.maxHeight);
                            _imageRect = computeRect(
                                Size(_imageInfo!.image.width.toDouble(),
                                    _imageInfo!.image.height.toDouble()),
                                availableSpace);
                            if (_cropRect == null) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                _cropRect = _imageRect;
                                setState(() {});
                              });
                            }
                            if (_cropRect == null) {
                              return const SizedBox.shrink();
                            }
                            return CustomPaint(
                              foregroundPainter: CropLayer2(_cropRect!),
                              willChange: true,
                              child: Image(
                                key: globalKey,
                                image: _image,
                                fit: BoxFit.contain,
                              ),
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        left: _cropRect?.left ?? 0,
                        top: _cropRect?.top ?? 0,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            _cropRect = _updateRectTopLeft(details);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      Positioned(
                        left: _cropRect?.right,
                        top: _cropRect?.top,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            _cropRect = _updateRectTopRight(details);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      Positioned(
                        left: _cropRect?.left,
                        top: _cropRect?.bottom,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            _cropRect = _updateRectBottomLeft(details);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      Positioned(
                        left: _cropRect?.right,
                        top: _cropRect?.bottom,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            _cropRect = _updateRectBottomRight(details);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      );
    }
  }

  Rect _updateRectTopLeft(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        _cropRect!.topLeft + details.delta, _cropRect!.bottomRight);

    return _imageRect!.intersect(newRect);
  }

  Rect _updateRectTopRight(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        _cropRect!.topLeft +
            Offset(
              0,
              details.delta.dy,
            ),
        _cropRect!.bottomRight + Offset(details.delta.dx, 0));
    return _imageRect!.intersect(newRect);
  }

  Rect _updateRectBottomLeft(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        _cropRect!.topLeft +
            Offset(
              details.delta.dx,
              0,
            ),
        _cropRect!.bottomRight + Offset(0, details.delta.dy));
    return _imageRect!.intersect(newRect);
  }

  Rect _updateRectBottomRight(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        _cropRect!.topLeft, _cropRect!.bottomRight + details.delta);

    return _imageRect!.intersect(newRect);
  }
}

Rect computeRect(Size imageSize, Rect availableSpace) {
  final fittedSizes =
      applyBoxFit(BoxFit.contain, imageSize, availableSpace.size);
  final destinationSize = fittedSizes.destination;
  return Rect.fromPoints(Offset.zero, destinationSize.bottomRight(Offset.zero));
}

class _Result extends StatelessWidget {
  const _Result({Key? key, required this.bytes}) : super(key: key);
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.memory(bytes)));
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';

import 'crop_layer.dart';

class CroppingArea extends StatefulWidget {
  const CroppingArea({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<CroppingArea> createState() => _CroppingAreaState();
}

class _CroppingAreaState extends State<CroppingArea> {
  static const double dotSize = 20;
  late MemoryImage _image;
  Rect croppingRect = Rect.zero;

  Rect imageRect = Rect.zero;

  Rect get backShiftedCroppingRect {
    return Rect.fromPoints(
        croppingRect.topLeft - Offset(dotSize / 2, dotSize / 2),
        croppingRect.bottomRight - Offset(dotSize / 2, dotSize / 2));
  }

  static final GlobalKey _globalKey = GlobalKey();

  Rect _updateRectBottomLeft(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        croppingRect.topLeft +
            Offset(
              details.delta.dx,
              0,
            ),
        croppingRect.bottomRight + Offset(0, details.delta.dy));

    double cropLeft = newRect.left;
    double cropBottom = newRect.bottom;

    if (cropLeft < imageRect.left) {
      cropLeft = imageRect.left;
    }
    if (cropBottom > imageRect.bottom) {
      cropBottom = imageRect.bottom;
    }
    return Rect.fromPoints(
        Offset(cropLeft, newRect.top), Offset(newRect.right, cropBottom));
  }

  Rect _updateRectTopRight(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        croppingRect.topLeft +
            Offset(
              0,
              details.delta.dy,
            ),
        croppingRect.bottomRight + Offset(details.delta.dx, 0));

    double cropRight = newRect.right;
    double cropTop = newRect.top;

    if (cropTop < imageRect.top) {
      cropTop = imageRect.top;
    }
    if (cropRight > imageRect.right) {
      cropRight = imageRect.right;
    }
    return Rect.fromPoints(
        Offset(newRect.left, cropTop), Offset(cropRight, newRect.bottom));
  }

  Rect _updateRectTopLeft(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        croppingRect.topLeft + details.delta, croppingRect.bottomRight);

    double cropLeft = newRect.left;
    double cropTop = newRect.top;

    if (cropTop < imageRect.top) {
      cropTop = imageRect.top;
    }
    if (cropLeft < imageRect.left) {
      cropLeft = imageRect.left;
    }
    return Rect.fromPoints(Offset(cropLeft, cropTop), newRect.bottomRight);
  }

  Rect _updateRectBottomRight(DragUpdateDetails details) {
    Rect newRect = Rect.fromPoints(
        croppingRect.topLeft, croppingRect.bottomRight + details.delta);

    double cropBottom = newRect.bottom;
    double cropRight = newRect.right;

    if (cropRight > imageRect.right) {
      cropRight = imageRect.right;
    }
    if (cropBottom > imageRect.bottom) {
      cropBottom = imageRect.bottom;
    }
    return Rect.fromPoints(newRect.topLeft, Offset(cropRight, cropBottom));
  }

  bool isLoading = false;

  Future<Size> getImageSize() async {
    final ImageStream stream = _image.resolve(ImageConfiguration.empty);
    final Completer<Size> completer = Completer<Size>();
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, _) {
      completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()));
      stream.removeListener(listener);
    });
    stream.addListener(listener);
    return completer.future;
  }

  bool test = true;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _image = MemoryImage(widget.bytes);
  }

  Offset? startPoint = null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final imageSize = await getImageSize();
            final size = imageRect.size;
            final x =
                backShiftedCroppingRect.left / size.width * imageSize.width;
            final y =
                backShiftedCroppingRect.top / size.height * imageSize.height;
            final width = (croppingRect.width) / size.width * imageSize.width;
            final height =
                (croppingRect.height) / size.height * imageSize.height;

            final bytes = await NativeImageCropper.cropRect(
                bytes: widget.bytes,
                x: x.toInt(),
                y: y.toInt(),
                width: width.toInt(),
                height: height.toInt());
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Result(bytes: bytes)));
          },
          child: Text('CROP'),
        ),
        Container(
          child: Container(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(dotSize / 2),
                  child: GestureDetector(
                    onPanStart: (details) {
                      startPoint = details.localPosition;
                    },
                    onPanEnd: (details) {
                      startPoint = null;
                    },
                    onPanUpdate: (details) {
                      if (startPoint != null) {
                        if (backShiftedCroppingRect.contains(startPoint!)) {
                          var localPosition = details.localPosition;
                          var x = localPosition.dx;

                          if (x < 0) {
                            x = 0;
                          }
                          if (x > imageRect.size.width) {
                            x = imageRect.size.width;
                          }
                          var y = localPosition.dy;
                          if (y < 0) {
                            y = 0;
                          }
                          if (y > imageRect.size.height) {
                            y = imageRect.size.height;
                          }

                          Rect newRect = croppingRect.shift(details.delta);
                          if (newRect.right > imageRect.right) {
                            newRect = Rect.fromPoints(croppingRect.topLeft,
                                Offset(imageRect.right, croppingRect.bottom));
                          }
                          if (newRect.left < imageRect.left) {
                            newRect = Rect.fromPoints(
                                Offset(imageRect.left, croppingRect.top),
                                croppingRect.bottomRight);
                          }

                          if (newRect.top < imageRect.top) {
                            newRect = Rect.fromPoints(
                                Offset(croppingRect.left, imageRect.top),
                                croppingRect.bottomRight);
                          }
                          if (newRect.bottom > imageRect.bottom) {
                            newRect = Rect.fromPoints(croppingRect.topLeft,
                                Offset(croppingRect.right, imageRect.bottom));
                          }

                          startPoint = Offset(x, y);
                          croppingRect = newRect;
                          setState(() {});
                          startPoint = details.localPosition;
                        }
                      }
                    },
                    child: CustomPaint(
                      foregroundPainter: CropLayer.CropPainter(
                        rect: backShiftedCroppingRect,
                        callback: (Size imageScreenSize) {
                          if (imageRect == Rect.zero) {
                            if (imageScreenSize == Size(0, 0)) {
                              return;
                            }
                            imageRect = Rect.fromPoints(
                                Offset(dotSize / 2, dotSize / 2),
                                Offset(imageScreenSize.width + dotSize / 2,
                                    imageScreenSize.height + dotSize / 2));
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              setState(() {});
                            });
                          }
                          if (croppingRect == Rect.zero) {
                            if (imageScreenSize == Size(0, 0)) {
                              return;
                            }
                            croppingRect = imageRect;
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) async {
                              setState(() {});
                            });
                          }
                        },
                      ),
                      willChange: true,
                      child: Image(
                        key: _globalKey,
                        image: _image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: croppingRect.left - dotSize / 2,
                  top: croppingRect.top - dotSize / 2,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      croppingRect = _updateRectTopLeft(details);
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
                  left: croppingRect.right - dotSize / 2,
                  top: croppingRect.bottom - dotSize / 2,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      croppingRect = _updateRectBottomRight(details);
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
                  left: croppingRect.right - dotSize / 2,
                  top: croppingRect.top - dotSize / 2,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      croppingRect = _updateRectTopRight(details);
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
                  left: croppingRect.left - dotSize / 2,
                  top: croppingRect.bottom - dotSize / 2,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      croppingRect = _updateRectBottomLeft(details);
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
            ),
          ),
        ),
      ],
    );
  }
}

class Result extends StatelessWidget {
  const Result({Key? key, required this.bytes}) : super(key: key);
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Image.memory(bytes));
  }
}

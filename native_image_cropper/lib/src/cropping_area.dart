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
  static const double dotSize = 60;
  late MemoryImage _image;
  Rect rect = Rect.largest;

  static final GlobalKey _globalKey = GlobalKey();

  Rect _updateRectTopLeft(BuildContext context, Offset globalPosition) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Rect.zero;
    }
    var localPosition = box.globalToLocal(globalPosition);
    var x = localPosition.dx;
    if (x < 0) {
      x = 0;
    }
    if (x > box.size.width) {
      x = box.size.width;
    }
    var y = localPosition.dy;
    if (y < 0) {
      y = 0;
    }
    if (y > box.size.height) {
      y = box.size.height;
    }
    return Rect.fromPoints(Offset(x, y), rect.bottomRight);
  }

  Rect _updateRectTopRight(BuildContext context, Offset globalPosition) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Rect.zero;
    }
    var localPosition = box.globalToLocal(globalPosition);
    var x = localPosition.dx;
    if (x < 0) {
      x = 0;
    }
    if (x > box.size.width) {
      x = box.size.width;
    }
    var y = localPosition.dy;
    if (y < 0) {
      y = 0;
    }
    if (y > box.size.height) {
      y = box.size.height;
    }
    return Rect.fromPoints(
        Offset(rect.left, y), Offset(x, rect.bottomRight.dy));
  }

  Rect _updateRectBottomRight(BuildContext context, Offset globalPosition) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Rect.zero;
    }
    var localPosition = box.globalToLocal(globalPosition);
    var x = localPosition.dx;
    if (x < 0) {
      x = 0;
    }
    if (x > box.size.width) {
      x = box.size.width;
    }
    var y = localPosition.dy;
    if (y < 0) {
      y = 0;
    }
    if (y > box.size.height) {
      y = box.size.height;
    }
    return Rect.fromPoints(rect.topLeft, Offset(x, y));
  }

  Rect _updateRectBottomLeft(BuildContext context, Offset globalPosition) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Rect.zero;
    }
    var localPosition = box.globalToLocal(globalPosition);
    var x = localPosition.dx;
    if (x < 0) {
      x = 0;
    }
    if (x > box.size.width) {
      x = box.size.width;
    }
    var y = localPosition.dy;
    if (y < 0) {
      y = 0;
    }
    if (y > box.size.height) {
      y = box.size.height;
    }
    return Rect.fromPoints(Offset(x, rect.top), Offset(rect.right, y));
  }

  Size getContainerSize(BuildContext context) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Size(0, 0);
    }
    return box.size;
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
      box?.markNeedsPaint();
      box?.markNeedsLayoutForSizedByParentChange();
      box?.markNeedsLayout();
      print('addPostFrameCallback');
      print(box?.size);
    });
    WidgetsBinding.instance.endOfFrame.then((_) {
      final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
      box?.markNeedsPaint();
      box?.markNeedsLayoutForSizedByParentChange();
      box?.markNeedsLayout();

      print('endOfFrame');
      print(box?.size);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies');
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    print(box?.size);
  }

  @override
  void didUpdateWidget(covariant CroppingArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    print(box?.size);
  }

  Offset? _startPoint;

  @override
  Widget build(BuildContext context) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    print("BUILD");
    if (box != null && !isLoading) {
      final size = box.size;
      if (size != Size.zero) {
        rect = box.paintBounds;
        isLoading = true;

        print('Box: ${size} - ratio: ${size.height / size.width}');
      }
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            if (box != null) {
              final imageSize = await getImageSize();
              final size = box.size;
              final x = rect.left / size.width * imageSize.width;
              final y = rect.top / size.height * imageSize.height;
              final width = (rect.width) / size.width * imageSize.width;
              final height = (rect.height) / size.height * imageSize.height;

              final bytes = await NativeImageCropper.cropRect(
                  bytes: widget.bytes,
                  x: x.toInt(),
                  y: y.toInt(),
                  width: width.toInt(),
                  height: height.toInt());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Result(bytes: bytes)));
            }
          },
          child: Text('CROP'),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              color: Colors.red,
              child: Stack(
                children: [
                  GestureDetector(
                    onPanStart: (details) {
                      _startPoint = details.localPosition;
                    },
                    onPanEnd: (details) {
                      _startPoint = null;
                    },
                    onPanUpdate: (details) {
                      if (_startPoint != null) {
                        if (rect.contains(_startPoint!)) {
                          var localPosition = details.localPosition;
                          var x = localPosition.dx;

                          final box = _globalKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box == null) {
                            return;
                          }
                          if (x < 0) {
                            x = 0;
                          }
                          if (x > box.size.width) {
                            x = box.size.width;
                          }
                          var y = localPosition.dy;
                          if (y < 0) {
                            y = 0;
                          }
                          if (y > box.size.height) {
                            y = box.size.height;
                          }
                          Rect newRect = rect.shift(details.delta);
                          if (newRect.right > box.size.width) {
                            newRect = Rect.fromPoints(rect.topLeft,
                                Offset(box.size.width, rect.bottom));
                          }
                          if (newRect.left < 0) {
                            newRect = Rect.fromPoints(
                                Offset(0, rect.top), rect.bottomRight);
                          }

                          if (newRect.top < 0) {
                            newRect = Rect.fromPoints(
                                Offset(rect.left, 0), rect.bottomRight);
                          }
                          if (newRect.bottom > box.size.height) {
                            newRect = Rect.fromPoints(rect.topLeft,
                                Offset(rect.right, box.size.height));
                          }

                          _startPoint = Offset(x, y);
                          rect = newRect;
                          setState(() {});
                        }
                      }
                    },
                    child: CustomPaint(
                      foregroundPainter: CropLayer(
                        rect,
                      ),
                      willChange: true,
                      child: Image(
                        key: _globalKey,
                        image: _image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    left: rect.left - dotSize / 2,
                    top: rect.top - dotSize / 2,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        rect =
                            _updateRectTopLeft(context, details.globalPosition);
                        setState(() {});
                      },
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  Positioned(
                    left: rect.left - dotSize / 2,
                    top: rect.bottom - dotSize / 2,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        rect = _updateRectBottomLeft(
                            context, details.globalPosition);
                        setState(() {});
                      },
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  Positioned(
                    left: rect.right - dotSize / 2,
                    top: rect.top - dotSize / 2,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        rect = _updateRectTopRight(
                            context, details.globalPosition);
                        setState(() {});
                      },
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  Positioned(
                    left: rect.right - dotSize / 2,
                    top: rect.bottom - dotSize / 2,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        rect = _updateRectBottomRight(
                            context, details.globalPosition);
                        setState(() {});
                      },
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
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

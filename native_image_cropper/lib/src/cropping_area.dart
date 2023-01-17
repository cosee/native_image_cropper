import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper/src/rect_area.dart';

class CroppingArea extends StatefulWidget {
  const CroppingArea({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<CroppingArea> createState() => _CroppingAreaState();
}

class _CroppingAreaState extends State<CroppingArea> {
  static const double dotSize = 200;

  Point leftTop = const Point(
    0,
    0,
  );
  Point leftBottom = const Point(
    0,
    0,
  );
  Point rightBottom = const Point(
    0,
    0,
  );
  Point rightTop = const Point(
    0,
    0,
  );
  static final GlobalKey _globalKey = GlobalKey();

  Point _updateRectPosition(BuildContext context, Offset position) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Point(0, 0);
    }
    var localPosition = box.globalToLocal(position);
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
    return Point(x, y);
  }

  Size getContainerSize(BuildContext context) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Size(0, 0);
    }
    return box.size;
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final box = _globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && !isLoading) {
      final size = box.size;
      rightTop = Point(size.width, 0);
      leftBottom = Point(0, size.height);
      rightBottom = Point(size.width, size.height);
      isLoading = true;
      //print(box.localToGlobal(Offset.zero));
      print('Box: ${size} - ratio: ${size.height / size.width}');
    }
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final bytes = await NativeImageCropper.cropRect(
                bytes: widget.bytes,
                x: leftTop.x.toInt(),
                y: leftTop.y.toInt(),
                width: (rightBottom.x - leftBottom.x).toInt(),
                height: (rightBottom.y - leftTop.y).toInt());
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Result(bytes: bytes)));
          },
          child: Text('CROP'),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              color: Colors.red,
              child: SizedBox.expand(
                child: FittedBox(
                  child: Stack(
                    children: [
                      CustomPaint(
                        foregroundPainter: RectAreaPaint(
                          Rect.fromPoints(
                              Offset(
                                  leftTop.x.toDouble(), leftTop.y.toDouble()),
                              box != null
                                  ? Offset(rightTop.x.toDouble(),
                                      leftBottom.y.toDouble())
                                  : Offset.zero),
                        ),
                        child: Image.memory(
                          key: _globalKey,
                          widget.bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                      /* if (box == null)
                        Positioned.fill(
                          child: Container(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      else
                        Positioned.fill(
                          child: Builder(builder: (context) {
                            return Container(
                              color: Colors.grey.withOpacity(0.5),
                              margin: EdgeInsets.only(
                                left: leftTop.x.toDouble(),
                                top: leftTop.y.toDouble(),
                              ),
                            );
                          }),
                        ),*/
                      /*Container(
                      color: Colors.grey.withOpacity(0.5),
                      margin: EdgeInsets.only(
                          left: leftTop.x.toDouble(), top: leftTop.y.toDouble()),
                      width: getContainerSize(context).width - leftTop.x,
                      height: getContainerSize(context).height - leftTop.y,
                    ),*/
                      Positioned(
                        left: leftTop.x.toDouble() - dotSize / 2,
                        top: leftTop.y.toDouble() - dotSize / 2,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            leftTop = _updateRectPosition(
                                context, details.globalPosition);
                            leftBottom = Point(leftTop.x, leftBottom.y);
                            rightTop = Point(rightTop.x, leftTop.y);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      Positioned(
                        left: leftBottom.x.toDouble() - dotSize / 2,
                        top: leftBottom.y.toDouble() - dotSize / 2,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            print(details.globalPosition);
                            leftBottom = _updateRectPosition(
                                context, details.globalPosition);
                            leftTop = Point(leftBottom.x, leftTop.y);
                            rightBottom = Point(rightBottom.x, leftBottom.y);

                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      Positioned(
                        left: rightTop.x.toDouble() - dotSize / 2,
                        top: rightTop.y.toDouble() - dotSize / 2,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            rightTop = _updateRectPosition(
                                context, details.globalPosition);
                            leftTop = Point(leftTop.x, rightTop.y);
                            rightBottom = Point(rightTop.x, rightBottom.y);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      Positioned(
                        left: rightBottom.x.toDouble() - dotSize / 2,
                        top: rightBottom.y.toDouble() - dotSize / 2,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            rightBottom = _updateRectPosition(
                                context, details.globalPosition);
                            leftBottom = Point(leftBottom.x, rightBottom.y);
                            rightTop = Point(rightBottom.x, rightTop.y);
                            print(rightBottom);
                            setState(() {});
                          },
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

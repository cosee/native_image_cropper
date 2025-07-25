import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_ios/native_image_cropper_ios.dart';
import 'package:native_image_cropper_ios_example/icon_button.dart';
import 'package:native_image_cropper_ios_example/result.dart';
import 'package:native_image_cropper_ios_example/slider.dart';
import 'package:native_image_cropper_ios_example/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String imageName = 'sail-boat';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeImageCropperIOSPlugin = NativeImageCropperIOS();
  ImageFormat _format = ImageFormat.jpg;
  late final Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = _getBytes();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CustomThemes.theme,
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          automaticBackgroundVisibility: false,
          heroTag: 'home',
          transitionBetweenRoutes: false,
          middle: Text(
            'Native Image Cropper iOS Example',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
        child: FutureBuilder<Uint8List>(
          future: _bytesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final bytes = snapshot.data;
              if (bytes != null) {
                return Column(
                  children: [
                    Image(
                      image: MemoryImage(bytes),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          flex: 2,
                          child: ImageFormatSlider(
                            onValueChanged: (value) => _format = value,
                          ),
                        ),
                        Flexible(
                          child: CupertinoIconButton(
                            icon: const Icon(
                              CupertinoIcons.crop,
                              color: CupertinoColors.black,
                            ),
                            onPressed: () => unawaited(
                              _crop(
                                context: context,
                                bytes: bytes,
                                method: _nativeImageCropperIOSPlugin.cropRect,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: CupertinoIconButton(
                            shape: BoxShape.circle,
                            icon: const Icon(
                              CupertinoIcons.crop,
                              color: CupertinoColors.black,
                            ),
                            onPressed: () => unawaited(
                              _crop(
                                context: context,
                                bytes: bytes,
                                method: _nativeImageCropperIOSPlugin.cropOval,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _crop({
    required BuildContext context,
    required Uint8List bytes,
    required Future<Uint8List> Function({
      required Uint8List bytes,
      required int x,
      required int y,
      required int width,
      required int height,
      required ImageFormat format,
    })
    method,
  }) async {
    final croppedBytes = await method(
      bytes: bytes,
      x: 1200,
      y: 900,
      width: 600,
      height: 600,
      format: _format,
    );

    if (context.mounted) {
      return Navigator.push<void>(
        context,
        CupertinoPageRoute(
          builder: (context) =>
              ResultPage(bytes: croppedBytes, format: _format),
        ),
      );
    }
  }

  Future<Uint8List> _getBytes() async {
    final byteData = await rootBundle.load('assets/${MyApp.imageName}.png');
    return byteData.buffer.asUint8List();
  }
}

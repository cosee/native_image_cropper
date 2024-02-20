import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_macos/native_image_cropper_macos.dart';
import 'package:native_image_cropper_macos_example/icon_button.dart';
import 'package:native_image_cropper_macos_example/result.dart';
import 'package:native_image_cropper_macos_example/slider.dart';
import 'package:native_image_cropper_macos_example/themes.dart';

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
  final _nativeImageCropperMacOSPlugin = NativeImageCropperMacOS();
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CustomThemes.theme,
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          heroTag: 'home',
          transitionBetweenRoutes: false,
          middle: Text(
            'Native Image Cropper MacOS Example',
            style: TextStyle(color: CupertinoColors.white),
          ),
        ),
        child: FutureBuilder<Uint8List>(
          // ignore: discarded_futures, build method cannot be marked async.
          future: _getBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final bytes = snapshot.data;
              if (bytes != null) {
                return Column(
                  children: [
                    Expanded(
                      child: Image(
                        image: MemoryImage(bytes),
                        fit: BoxFit.contain,
                      ),
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
                                method: _nativeImageCropperMacOSPlugin.cropRect,
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
                                method: _nativeImageCropperMacOSPlugin.cropOval,
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
    }) method,
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

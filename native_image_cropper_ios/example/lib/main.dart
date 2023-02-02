import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_image_cropper_ios/native_image_cropper_ios.dart';
import 'package:native_image_cropper_ios_example/themes.dart';
import 'package:path_provider/path_provider.dart';

part 'result.dart';
part 'slider.dart';
part 'snack_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String image = 'sail-boat.png';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeImageCropperIOSPlugin = NativeImageCropperIOS();
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
            'Native Image Cropper iOS Example',
            style: TextStyle(color: Colors.white),
          ),
        ),
        child: FutureBuilder<Uint8List>(
          future: _getBytes(),
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
                          child: _ImageFormatSlider(
                            onValueChanged: (value) => _format = value,
                          ),
                        ),
                        Flexible(
                          child: CupertinoButton(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                border: Border.fromBorderSide(BorderSide()),
                              ),
                              child: const Icon(
                                CupertinoIcons.crop,
                                color: CupertinoColors.black,
                              ),
                            ),
                            onPressed: () => _crop(
                              context: context,
                              bytes: bytes,
                              method: _nativeImageCropperIOSPlugin.cropRect,
                            ),
                          ),
                        ),
                        Flexible(
                          child: CupertinoButton(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(BorderSide()),
                              ),
                              child: const Icon(
                                CupertinoIcons.crop,
                                color: CupertinoColors.black,
                              ),
                            ),
                            onPressed: () => _crop(
                              context: context,
                              bytes: bytes,
                              method: _nativeImageCropperIOSPlugin.cropOval,
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

    if (mounted) {
      return Navigator.push<void>(
        context,
        CupertinoPageRoute(
          builder: (context) => _ResultPage(bytes: croppedBytes),
        ),
      );
    }
  }

  Future<Uint8List> _getBytes() async {
    final byteData = await rootBundle.load('assets/${MyApp.image}');
    return byteData.buffer.asUint8List();
  }
}

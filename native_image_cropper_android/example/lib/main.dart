import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';
import 'package:native_image_cropper_android_example/button.dart';
import 'package:native_image_cropper_android_example/dropdown.dart';
import 'package:native_image_cropper_android_example/result.dart';
import 'package:native_image_cropper_android_example/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String imageName = 'sail-boat.png';

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeImageCropperAndroidPlugin = NativeImageCropperAndroid();
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomThemes.theme(context),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Image Cropper Android Example'),
        ),
        body: FutureBuilder<Uint8List>(
          // ignore: discarded_futures, build method cannot be marked async.
          future: _getBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final bytes = snapshot.data;
              if (bytes != null) {
                return Column(
                  children: [
                    Image(
                      image: MemoryImage(bytes),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImageFormatDropdown(
                          onChanged: (value) => _format = value,
                        ),
                        RoundedIconButton(
                          onTap: () => unawaited(
                            _crop(
                              context: context,
                              bytes: bytes,
                              method: _nativeImageCropperAndroidPlugin.cropRect,
                            ),
                          ),
                          icon: const Icon(Icons.crop),
                        ),
                        RoundedIconButton(
                          shape: BoxShape.circle,
                          onTap: () => unawaited(
                            _crop(
                              context: context,
                              bytes: bytes,
                              method: _nativeImageCropperAndroidPlugin.cropOval,
                            ),
                          ),
                          icon: const Icon(Icons.crop),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
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
      x: 0,
      y: 0,
      width: 2999,
      height: 1999,
      format: _format,
    );

    if (context.mounted) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<ResultPage>(
          builder: (context) => ResultPage(
            bytes: croppedBytes,
            format: _format,
          ),
        ),
      );
    }
  }

  Future<Uint8List> _getBytes() async {
    final byteData = await rootBundle.load('assets/${MyApp.imageName}');
    return byteData.buffer.asUint8List();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_web/native_image_cropper_web.dart';
import 'package:native_image_cropper_web_example/button.dart';
import 'package:native_image_cropper_web_example/dropdown.dart';
import 'package:native_image_cropper_web_example/result.dart';
import 'package:native_image_cropper_web_example/themes.dart';

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
  final _nativeImageCropperWeb = NativeImageCropperPlugin();
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomThemes.theme(context),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Image Cropper Web Example'),
        ),
        body: FutureBuilder<Uint8List>(
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
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ImageFormatDropdown(
                          onChanged: (value) => _format = value,
                        ),
                        RoundedIconButton(
                          onTap: () => _crop(
                            context: context,
                            bytes: bytes,
                            method: _nativeImageCropperWeb.cropRect,
                          ),
                          icon: const Icon(Icons.crop),
                        ),
                        RoundedIconButton(
                          shape: BoxShape.circle,
                          onTap: () => _crop(
                            context: context,
                            bytes: bytes,
                            method: _nativeImageCropperWeb.cropOval,
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
    final byteData = await rootBundle.load('assets/${MyApp.imageName}.png');
    return byteData.buffer.asUint8List();
  }
}

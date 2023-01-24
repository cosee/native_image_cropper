import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeImageCropperAndroidPlugin = NativeImageCropperAndroid();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Image Cropper Android Example'),
        ),
        body: FutureBuilder<Uint8List>(
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
                        InkWell(
                          onTap: () => _crop(
                            context: context,
                            bytes: bytes,
                            method: _nativeImageCropperAndroidPlugin.cropRect,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide()),
                            ),
                            child: const Icon(Icons.crop),
                          ),
                        ),
                        InkWell(
                          onTap: () => _crop(
                            context: context,
                            bytes: bytes,
                            method: _nativeImageCropperAndroidPlugin.cropOval,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide()),
                            ),
                            child: const Icon(
                              Icons.crop,
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
    })
        method,
  }) async {
    final croppedBytes = await method(
      bytes: bytes,
      x: 1200,
      y: 900,
      width: 600,
      height: 600,
    );

    if (mounted) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<_ResultPage>(
          builder: (context) => _ResultPage(bytes: croppedBytes),
        ),
      );
    }
  }

  Future<Uint8List> _getBytes() async {
    final byteData = await rootBundle.load('assets/sail-boat.jpg');
    return byteData.buffer.asUint8List();
  }
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({required this.bytes});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Image'),
      ),
      body: Center(
        child: Image.memory(bytes),
      ),
    );
  }
}

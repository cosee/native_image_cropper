import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';
import 'package:native_image_cropper_android_example/themes.dart';
import 'package:path_provider/path_provider.dart';

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
  final _nativeImageCropperAndroidPlugin = NativeImageCropperAndroid();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomThemes.theme(context),
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
    final byteData = await rootBundle.load('assets/${MyApp.image}');
    return byteData.buffer.asUint8List();
  }
}

class _ResultPage extends StatefulWidget {
  const _ResultPage({required this.bytes});

  final Uint8List bytes;

  @override
  State<_ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<_ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Image'),
        actions: [
          IconButton(
            onPressed: _saveImage,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Center(
        child: Image.memory(widget.bytes),
      ),
    );
  }

  Future<void> _saveImage() async {
    final dir = (await getTemporaryDirectory()).path;
    final path = '$dir/${MyApp.image}';
    final file = File(path)..writeAsBytesSync(widget.bytes);
    await ImageGallerySaver.saveFile(
      path,
    );
    file.deleteSync();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved image in gallery!'),
        ),
      );
    }
  }
}

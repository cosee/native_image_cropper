import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_image_cropper_ios/native_image_cropper_ios.dart';
import 'package:native_image_cropper_ios_example/themes.dart';
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
  final _nativeImageCropperIOSPlugin = NativeImageCropperIOS();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CustomThemes.theme,
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Native Image Cropper iOS Example'),
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
                        CupertinoButton(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide()),
                            ),
                            child: const Icon(CupertinoIcons.crop),
                          ),
                          onPressed: () => _crop(
                            context: context,
                            bytes: bytes,
                            method: _nativeImageCropperIOSPlugin.cropRect,
                          ),
                        ),
                        CupertinoButton(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide()),
                            ),
                            child: const Icon(CupertinoIcons.crop),
                          ),
                          onPressed: () => _crop(
                            context: context,
                            bytes: bytes,
                            method: _nativeImageCropperIOSPlugin.cropOval,
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

class _ResultPage extends StatefulWidget {
  const _ResultPage({required this.bytes});

  final Uint8List bytes;

  @override
  State<_ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<_ResultPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Native Image Cropper iOS Example'),
          trailing: CupertinoButton(
            onPressed: _saveImage,
            child: const Icon(CupertinoIcons.download_circle),
          ),
        ),
        child: Center(
          child: Image.memory(widget.bytes),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    final dir = (await getTemporaryDirectory()).path;
    final path = '$dir/${MyApp.image}';
    final file = File(path)..writeAsBytesSync(widget.bytes);
    await ImageGallerySaver.saveFile(path);
    file.deleteSync();
    if (mounted) {
      await showCupertinoDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const _CupertinoSnackBar('Saved image to gallery!'),
      );
    }
  }
}

class _CupertinoSnackBar extends StatefulWidget {
  const _CupertinoSnackBar(this.message);

  final String message;

  @override
  State<_CupertinoSnackBar> createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<_CupertinoSnackBar> {
  @override
  void initState() {
    super.initState();
    _closeDialog();
  }

  Future<void> _closeDialog() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(widget.message),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CropController _controller;
  CropMode _mode = CropMode.rect;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _controller = CropController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomTheme.theme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Image Cropper Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<Uint8List>(
            future: _getBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final bytes = snapshot.data;
                if (bytes != null) {
                  return Column(
                    children: [
                      CropPreview(
                        controller: _controller,
                        bytes: bytes,
                        mode: _mode,
                        layerOptions:
                            CropLayerOptions(aspectRatio: _aspectRatio),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DropdownButton<double?>(
                            value: _aspectRatio,
                            items: const [
                              DropdownMenuItem(
                                child: Text('Custom'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1:1'),
                              ),
                              DropdownMenuItem(
                                value: 4 / 3,
                                child: Text('4:3'),
                              ),
                              DropdownMenuItem(
                                value: 16 / 9,
                                child: Text('16:9'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _aspectRatio = value),
                          ),
                          InkWell(
                            onTap: () => setState(() => _mode = CropMode.rect),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color:
                                    _mode == CropMode.rect ? Colors.grey : null,
                                border:
                                    const Border.fromBorderSide(BorderSide()),
                              ),
                              child: const Icon(
                                Icons.crop,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _mode = CropMode.oval),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _mode == CropMode.oval ? Colors.grey : null,
                                border:
                                    const Border.fromBorderSide(BorderSide()),
                              ),
                              child: const Icon(
                                Icons.crop,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _cropImage(context),
                          child: const Text('CROP'),
                        ),
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
      ),
    );
  }

  Future<Uint8List> _getBytes() async {
    final byteData = await rootBundle.load('assets/sail-boat.jpg');
    return byteData.buffer.asUint8List();
  }

  Future<void> _cropImage(BuildContext context) async {
    final bytes = await _controller.crop();
    if (mounted) {
      return Navigator.push<void>(
        context,
        MaterialPageRoute<_ResultPage>(
          builder: (context) => _ResultPage(bytes: bytes),
        ),
      );
    }
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

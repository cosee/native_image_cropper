import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper/native_image_cropper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  Future<Uint8List> getImage() async {
    final byteData = await rootBundle.load('assets/test_image.png');
    return byteData.buffer.asUint8List();
  }

  final controller = CropController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FutureBuilder<Uint8List>(
            future: getImage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final bytes = await controller.crop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => _Result(bytes: bytes)));
                      },
                      child: const Text('CROP'),
                    ),
                    Expanded(
                      child: CropPreview(
                        controller: controller,
                        bytes: snapshot.data!,
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({Key? key, required this.bytes}) : super(key: key);
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.memory(bytes)));
  }
}

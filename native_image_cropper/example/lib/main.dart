import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper/native_image_cropper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Uint8List> getImage() async {
    final byteData = await rootBundle.load('assets/test_image.png');
    return byteData.buffer.asUint8List();
  }

  final controller = CropController();

  CropMode mode = CropMode.rect;

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
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final bytes = await controller.crop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => _Result(bytes: bytes)));
                        },
                        child: const Text('CROP'),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() => mode = CropMode.rect),
                          child: const Text('RECT'),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => mode = CropMode.oval),
                          child: const Text('OVAL'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: CropPreview(
                        controller: controller,
                        bytes: snapshot.data!,
                        mode: mode,
                        dragPointBuilder: (size, position) {
                          switch (position) {
                            case CropDragPointPosition.topLeft:
                              return Container(
                                width: size,
                                height: size,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              );
                            case CropDragPointPosition.topRight:
                              return Container(
                                width: size,
                                height: size,
                                color: Colors.green,
                              );
                            case CropDragPointPosition.bottomLeft:
                              return Container(
                                width: size,
                                height: size,
                                color: Colors.yellow,
                              );
                            case CropDragPointPosition.bottomRight:
                              return Container(
                                width: size,
                                height: size,
                                color: Colors.red,
                              );
                          }
                        },
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

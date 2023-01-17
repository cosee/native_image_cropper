import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper/native_image_cropper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Uint8List> getImage() async {
    final byteData = await rootBundle.load('assets/test_image.png');
    getImageSize(MemoryImage(byteData.buffer.asUint8List())).then((value) =>
        print('Original: $value - ratio: ${value.height / value.width}'));
    return byteData.buffer.asUint8List();
  }

  Future<Size> getImageSize(ImageProvider imageProvider) async {
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final Completer<Size> completer = Completer<Size>();
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, _) {
      completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()));
      stream.removeListener(listener);
    });
    stream.addListener(listener);
    return completer.future;
  }

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
                    Expanded(
                      child: CroppingArea(
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

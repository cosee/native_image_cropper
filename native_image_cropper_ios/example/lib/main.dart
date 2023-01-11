import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper_ios/native_image_cropper_ios.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nativeImageCropperAndroidPlugin = NativeImageCropperIOS();
  Uint8List? _inputImage;
  Uint8List? _outputImage;

  @override
  void initState() {
    super.initState();
    initTryOutPlugin();
  }

  // TODO real example
  Future<void> initTryOutPlugin() async {
    final ByteData bytes = await rootBundle.load('assets/test_image.png');
    Uint8List inputByteList = bytes.buffer.asUint8List();
    setState(() {
      _inputImage = inputByteList;
    });

    Uint8List? croppedByteList =
        await _nativeImageCropperAndroidPlugin.cropRect(
            bytes: Uint8List.fromList(inputByteList),
            x: 200,
            y: 350,
            width: 450,
            height: 450);
    setState(() {
      _outputImage = croppedByteList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_inputImage != null)
              Column(children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Original"),
                ),
                Image.memory(
                  _inputImage!,
                  height: 300,
                )
              ]),
            if (_outputImage != null)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Cropped"),
                  ),
                  Image.memory(
                    _outputImage!,
                    height: 200,
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

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
  void initState() {
    super.initState();
    initTryOutPlugin();
  }

  // TODO real example
  Future<void> initTryOutPlugin() async {
    Uint8List? image = await _nativeImageCropperAndroidPlugin.cropRect(
        bytes: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9]),
        x: 0,
        y: 0,
        width: 3,
        height: 3);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Text("Test"),
      ),
    );
  }
}

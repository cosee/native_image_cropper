import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_image_cropper_web/native_image_cropper_web.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.bytes,
    required this.format,
  });

  final Uint8List bytes;
  final ImageFormat format;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Image'),
        actions: [
          IconButton(
            // TODO: Implement save button
            onPressed: () {},
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Center(
        child: Image.memory(widget.bytes),
      ),
    );
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:native_image_cropper_web/native_image_cropper_web.dart';
import 'package:native_image_cropper_web_example/main.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    required this.bytes,
    required this.format,
    super.key,
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

  void _saveImage() {
    final format = widget.format == ImageFormat.jpg ? 'jpeg' : 'png';
    final mimeType =
        widget.format == ImageFormat.jpg ? MimeType.jpeg : MimeType.png;
    unawaited(
      FileSaver.instance.saveFile(
        name: '${MyApp.imageName}.$format',
        bytes: widget.bytes,
        ext: format,
        mimeType: mimeType,
      ),
    );
  }
}

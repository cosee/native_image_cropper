import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/main.dart';

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

  Future<void> _saveImage() async {
    if (kIsWeb) {
      await _saveImageWeb();
    } else {
      await _saveImageFlutter();
    }
  }

  Future<void> _saveImageFlutter() async {
    final format = widget.format == ImageFormat.jpg ? 'jpg' : 'png';
    await Gal.putImageBytes(
      widget.bytes,
      name: '${MyApp.imageName}.$format',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved cropped image in gallery!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveImageWeb() async {
    final format = widget.format == ImageFormat.jpg ? 'jpeg' : 'png';
    final mimeType = widget.format == ImageFormat.jpg
        ? MimeType.jpeg
        : MimeType.png;

    await FileSaver.instance.saveFile(
      name: MyApp.imageName,
      bytes: widget.bytes,
      fileExtension: format,
      mimeType: mimeType,
    );
  }
}

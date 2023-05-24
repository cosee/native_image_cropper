import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_image_cropper_android/native_image_cropper_android.dart';
import 'package:native_image_cropper_android_example/main.dart';
import 'package:path_provider/path_provider.dart';

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
    final dir = (await getTemporaryDirectory()).path;
    final format = widget.format == ImageFormat.jpg ? 'jpg' : 'png';
    final path = '$dir/${MyApp.image}.$format';
    final file = File(path)..writeAsBytesSync(widget.bytes);
    final result =
        await ImageGallerySaver.saveFile(path) as Map<Object?, Object?>;
    file.deleteSync();

    if (mounted) {
      final isSuccess = result['isSuccess'] as bool?;
      SnackBar snackBar;
      if (isSuccess ?? false) {
        snackBar = const SnackBar(
          content: Text('Saved image in gallery!'),
          duration: Duration(seconds: 2),
        );
      } else {
        snackBar = const SnackBar(
          content: Text(
            'The image could not be saved to the gallery. Please allow the '
            'app to save images in the settings!',
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

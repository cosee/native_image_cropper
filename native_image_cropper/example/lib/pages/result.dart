import 'dart:async';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:native_image_cropper_example/main.dart';
import 'package:native_image_cropper_example/widgets/snack_bar.dart';
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
    if (kIsWeb) {
      _saveImageWeb();
    } else {
      switch (Platform.operatingSystem) {
        case 'android':
        case 'ios':
          return _saveImageMobile();
        case 'macos':
          return _saveImageMacOS();
        default:
          throw UnimplementedError('Saving image is not implemented');
      }
    }
  }

  Future<void> _saveImageMobile() async {
    final dir = (await getTemporaryDirectory()).path;
    final format = widget.format == ImageFormat.jpg ? 'jpg' : 'png';
    final path = '$dir/${MyApp.imageName}.$format';
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

  Future<void> _saveImageMacOS() async {
    final format = widget.format == ImageFormat.jpg ? 'jpeg' : 'png';
    final fileName = '${MyApp.imageName}.$format';
    final location = await getSaveLocation(suggestedName: fileName);
    final file =
        XFile.fromData(widget.bytes, mimeType: 'image/$format', name: fileName);
    if (location != null) {
      await file.saveTo(location.path);
      if (mounted) {
        unawaited(
          showCupertinoDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => const CupertinoSnackBar(message: 'Saved image!'),
          ),
        );
      }
    } else {
      if (mounted) {
        unawaited(
          showCupertinoDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) =>
                const CupertinoSnackBar(message: 'Failed to save image!'),
          ),
        );
      }
    }
  }

  void _saveImageWeb() {
    final format = widget.format == ImageFormat.jpg ? 'jpeg' : 'png';
    final mimeType =
        widget.format == ImageFormat.jpg ? MimeType.jpeg : MimeType.png;
    unawaited(
      FileSaver.instance.saveFile(
        name: MyApp.imageName,
        bytes: widget.bytes,
        ext: format,
        mimeType: mimeType,
      ),
    );
  }
}

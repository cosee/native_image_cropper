import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_image_cropper_ios/native_image_cropper_ios.dart';
import 'package:native_image_cropper_ios_example/main.dart';
import 'package:native_image_cropper_ios_example/snack_bar.dart';
import 'package:path_provider/path_provider.dart';

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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        heroTag: 'result',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Native Image Cropper iOS Example',
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          onPressed: _saveImage,
          child: const Icon(
            CupertinoIcons.download_circle,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: Center(
        child: Image.memory(widget.bytes),
      ),
    );
  }

  Future<void> _saveImage() async {
    final dir = (await getTemporaryDirectory()).path;
    final format = widget.format == ImageFormat.jpg ? 'jpg' : 'png';
    final path = '$dir/${MyApp.imageName}.$format';
    final file = File(path)..writeAsBytesSync(widget.bytes);
    await ImageGallerySaver.saveFile(path);
    file.deleteSync();

    if (mounted) {
      await showCupertinoDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) =>
            const CupertinoSnackBar(message: 'Saved image to gallery!'),
      );
    }
  }
}

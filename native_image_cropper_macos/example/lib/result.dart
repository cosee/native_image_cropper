import 'dart:async';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:native_image_cropper_macos/native_image_cropper_macos.dart';
import 'package:native_image_cropper_macos_example/main.dart';
import 'package:native_image_cropper_macos_example/snack_bar.dart';

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
    final format = widget.format == ImageFormat.jpg ? 'jpeg' : 'png';
    final fileName = '${MyApp.imageName}.$format';
    final path = await getSavePath(suggestedName: fileName);
    final file =
        XFile.fromData(widget.bytes, mimeType: 'image/$format', name: fileName);
    if (path != null) {
      await file.saveTo(path);
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
}

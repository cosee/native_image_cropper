part of 'main.dart';

class _ResultPage extends StatefulWidget {
  const _ResultPage({required this.bytes});

  final Uint8List bytes;

  @override
  State<_ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<_ResultPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        heroTag: 'result',
        transitionBetweenRoutes: false,
        middle: const Text(
          'Native Image Cropper iOS Example',
          style: TextStyle(color: Colors.white),
        ),
        trailing: CupertinoButton(
          onPressed: _saveImage,
          child: const Icon(
            CupertinoIcons.download_circle,
            color: Colors.white,
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
    final path = '$dir/${MyApp.image}';
    final file = File(path)..writeAsBytesSync(widget.bytes);
    await ImageGallerySaver.saveFile(path);
    file.deleteSync();

    if (mounted) {
      await showCupertinoDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const _CupertinoSnackBar('Saved image to gallery!'),
      );
    }
  }
}

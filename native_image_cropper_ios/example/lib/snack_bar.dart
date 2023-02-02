part of 'main.dart';

class _CupertinoSnackBar extends StatefulWidget {
  const _CupertinoSnackBar(this.message);

  final String message;

  @override
  State<_CupertinoSnackBar> createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<_CupertinoSnackBar> {
  @override
  void initState() {
    super.initState();
    _closeDialog();
  }

  Future<void> _closeDialog() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Text(widget.message),
    );
  }
}

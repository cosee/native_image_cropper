import 'package:flutter/cupertino.dart';

class CupertinoSnackBar extends StatefulWidget {
  const CupertinoSnackBar({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 2),
  });

  final String message;
  final Duration duration;

  @override
  State<CupertinoSnackBar> createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<CupertinoSnackBar> {
  @override
  void initState() {
    super.initState();
    _closeDialog();
  }

  Future<void> _closeDialog() async {
    await Future<void>.delayed(widget.duration);
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

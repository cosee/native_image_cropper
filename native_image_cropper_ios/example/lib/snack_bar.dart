import 'package:flutter/cupertino.dart';

class CupertinoSnackBar extends StatefulWidget {
  const CupertinoSnackBar({super.key, required this.message});

  final String message;

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

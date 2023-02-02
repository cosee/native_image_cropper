part of 'main.dart';

class _ImageFormatSlider extends StatefulWidget {
  const _ImageFormatSlider({required this.onValueChanged});

  final ValueChanged<ImageFormat> onValueChanged;

  @override
  State<_ImageFormatSlider> createState() => _ImageFormatSliderState();
}

class _ImageFormatSliderState extends State<_ImageFormatSlider> {
  ImageFormat _format = ImageFormat.jpg;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: Colors.transparent,
      middle: CupertinoSlidingSegmentedControl<ImageFormat>(
        backgroundColor: CupertinoColors.systemGrey3,
        groupValue: _format,
        thumbColor: CustomThemes.yellow,
        children: const {
          ImageFormat.jpg: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'JPG',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          ImageFormat.png: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'PNG',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            widget.onValueChanged.call(value);
            setState(() => _format = value);
          }
        },
      ),
    );
  }
}

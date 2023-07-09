import 'package:flutter/material.dart';
import 'package:nurie_3/screen_pod.dart';

class SaveOrConvertButton extends StatelessWidget {
  const SaveOrConvertButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.color});

  final VoidCallback? onPressed;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);
    final sizeClass = screen.sizeClass;

    return SizedBox(
      width: screen.designW(340),
      height: screen.designH(60),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(
          title,
          style: TextStyle(fontSize: sizeClass == ScreenSizeClass.phone ? 28 : 48, letterSpacing: 4),
        ),
      ),
    );
  }
}

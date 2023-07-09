import 'package:flutter/material.dart';
import 'package:nurie_3/constants.dart';
import 'package:nurie_3/screen_pod.dart';

class ImagePickButton extends StatelessWidget {
  const ImagePickButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.icon,
      this.color = const Color(0xffff9500)});

  final VoidCallback? onPressed;
  final String title;
  final Icon icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);
    final sizeClass = screen.sizeClass;

    return SizedBox(
      width: screen.designW(160),
      height: screen.designH(60),
      child: ElevatedButton.icon(
        icon: icon,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
            iconSize: MaterialStateProperty.all(
                sizeClass == ScreenSizeClass.phone ? 24 : 48)),
        label: Text(
          title,
          style: TextStyle(
              fontSize: sizeClass == ScreenSizeClass.phone ? 20 : 40,
              fontFamily: mainFont,
              letterSpacing: 4),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

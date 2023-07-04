import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nurie_3/screen_pod.dart';

import 'constants.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.onPressed, required this.title});

  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);

    return SizedBox(
      width: screen.designW(340),
      height: screen.designH(60),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          title,
          style:
              TextStyle(fontSize: 28, fontFamily: mainFont, letterSpacing: 4),
        ),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
      ),
    );
  }
}

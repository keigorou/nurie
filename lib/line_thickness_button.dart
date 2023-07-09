import 'package:flutter/material.dart';

class LineThicknessButton extends StatelessWidget {
  const LineThicknessButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.fontSize});
  final VoidCallback? onPressed;
  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize, letterSpacing: 4),
        ));
  }
}

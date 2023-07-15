import 'package:flutter/material.dart';
import 'package:nurie_3/screen_pod.dart';

class DefaultImage extends StatelessWidget {
  const DefaultImage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);
    final sizeClass = screen.sizeClass;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screen.designH(40)),
            Container(
              width: screen.designW(200),
              height: screen.designH(200),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('assets/image_select_icon.png'))),
            ),
            SizedBox(height: screen.designH(40)),
            Center(
              child: Text(
                'カメラやアルバムから\nがぞうをえらぼう',
                style: TextStyle(
                    fontSize: sizeClass == ScreenSizeClass.phone ? 28 : 48,
                    letterSpacing: 8),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nurie_3/constants.dart';
import 'package:nurie_3/screen_pod.dart';

class SelectImage extends StatelessWidget {
  const SelectImage({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);

    return Center(
      child: Column(
        children: [
          SizedBox(height: screen.designH(40)),
          Container(
            width: screen.designW(200),
            height: screen.designH(200),
            decoration: const BoxDecoration(
                // color: Colors.amber,
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/icon3.png'))),
          ),
          SizedBox(height: screen.designH(40)),
          const Center(
            child: Text(
              'カメラやアルバムから\nがぞうをえらぼう',
              style: TextStyle(
                  fontFamily: mainFont, fontSize: 28, letterSpacing: 8),
            ),
          )
        ],
      ),
    );
  }
}

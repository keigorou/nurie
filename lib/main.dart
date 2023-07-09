import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nurie_3/constants.dart';

import 'home_page.dart';

void main() {
  const app = MyApp();

  final devicePreview = DevicePreview(builder: (_) => app,);
  if (kIsWeb) {
    runApp(devicePreview);
  } else {
    runApp(app);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: mainFont,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

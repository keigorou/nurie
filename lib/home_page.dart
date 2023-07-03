import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurie_3/image_file_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:nurie_3/screen_pod.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  File? _image;
  Uint8List? _imageBytes, _nurieImageBytes, salida;
  // bool _visible = false;

  final picker = ImagePicker();

  static const nurieChannel = MethodChannel("nurie_3.com/nurie");

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 1.0, end: 0.0).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getImageFromDevice(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    _image = File(pickedFile!.path);
    _imageBytes = await _image!.readAsBytes();

    setState(() {
      _imageBytes;
    });
  }

  _imageConvert(String methodName) async {
    final path = await ImageFileController.localPath;
    final imagePath = '$path/temp.jpeg';
    File tempFile = File(imagePath);
    var savedFile = await tempFile.writeAsBytes(_imageBytes!);
    _nurieImageBytes =
        await nurieChannel.invokeMethod(methodName, savedFile.path);

    setState(() {
      _nurieImageBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);
    // final sizeClass = screen.sizeClass;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('background.jpeg'), fit: BoxFit.fill)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: screen.designH(100)),
                    Stack(
                      children: [
                        Container(
                          width: screen.designW(400),
                          height: screen.designH(400),
                          child: _imageBytes != null
                                ? Image.memory(
                                    _nurieImageBytes!,
                                    width: screen.designW(400),
                                    height: screen.designH(400),
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox()
                          // decoration: BoxDecoration(color: Colors.amber),
                        ),
                        FadeTransition(
                          opacity: _animation,
                          child: Container(
                            child: _imageBytes != null
                                ? Image.memory(
                                    _imageBytes!,
                                    width: screen.designW(400),
                                    height: screen.designH(400),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: screen.designW(400),
                                    height: screen.designH(400),
                                    decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: AssetImage('1.jpeg'))),
                                  ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: _imagePickButtonList(screen),
                    ),
                    _imageBytes != null
                        ? FadeTransition(
                            opacity: _animation,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: TextButton(
                                onPressed: () async {
                                  await _imageConvert("image2NurieKernelSize5");
                                  showImageDialog();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                                child: const Text('塗り絵'),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.forward();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text('保存'),
                      ),
                    ),
                    _button(
                        onPressed: () =>
                            ImageGallerySaver.saveImage(_imageBytes!),
                        title: "保存する",
                        width: MediaQuery.of(context).size.width - 20,
                        height: 60,
                        color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Object?> showImageDialog() {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "test",
      context: context,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
          child: child,
        );
      },
      pageBuilder: (
        context,
        _,
        __,
      ) =>
          Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            // borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(5),
                child: _nurieImageBytes != null
                    ? Image.memory(
                        _nurieImageBytes!,
                        // width: MediaQuery.of(context).size.width - 20,
                        fit: BoxFit.contain,
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width - 20,
                        height: 300,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
              ElevatedButton(
                  onPressed: () =>
                      ImageGallerySaver.saveImage(_nurieImageBytes!),
                  child: Text('保存する'))
            ],
          ),
        ),
      ),
    );
  }

  Widget _button({
    required VoidCallback? onPressed,
    required String title,
    required double width,
    required double height,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: Text(title),
      ),
    );
  }

  Widget _imagePickButtonList(Screen screen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _button(
          onPressed: () => _getImageFromDevice(ImageSource.camera),
          title: "カメラ",
          width: screen.designW(150),
          height: screen.designH(50),
          color: Colors.teal,
        ),
        _button(
          onPressed: () => _getImageFromDevice(ImageSource.gallery),
          title: "ギャラリー",
           width: screen.designW(150),
          height: screen.designH(50),
          color: Colors.teal,
        ),
      ],
    );
  }
}

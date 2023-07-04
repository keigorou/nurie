import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurie_3/constants.dart';
import 'package:nurie_3/select_image_widget.dart';
import 'package:nurie_3/image_file_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:nurie_3/image_pick_button.dart';
import 'package:nurie_3/screen_pod.dart';

import 'button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  File? _image;
  Uint8List? _imageBytes, _nurieImageBytes, salida;

  final picker = ImagePicker();

  static const nurieChannel = MethodChannel("nurie_3.com/nurie");

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
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
    _controller.reset();

    setState(() {
      _nurieImageBytes = null;
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
                image: AssetImage('assets/background.jpeg'), fit: BoxFit.fill)),
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
                        SizedBox(
                            width: screen.designW(400),
                            height: screen.designH(400),
                            child: _nurieImageBytes != null
                                ? Image.memory(
                                    _nurieImageBytes!,
                                    width: screen.designW(400),
                                    height: screen.designH(400),
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox()),
                        FadeTransition(
                          opacity: _animation,
                          child: Container(
                              child: _imageBytes != null
                                  ? Image.memory(
                                      _imageBytes!,
                                      width: screen.designW(400),
                                      height: screen.designH(400),
                                      fit: BoxFit.contain,
                                    )
                                  // 画像を挿入する案内
                                  : SizedBox(
                                      width: screen.designW(400),
                                      height: screen.designH(400),
                                      child: const SelectImage())),
                        )
                      ],
                    ),
                    SizedBox(
                      height: screen.designH(20),
                    ),
                    _imagePickButtonList(screen),
                    SizedBox(
                      height: screen.designH(20),
                    ),
                    MyButton(
                      onPressed: _imageBytes != null
                          ? () async {
                              _imageConvert("image2NurieKernelSize5");
                              _controller.forward();
                            }
                          : null,
                      title: 'ぬりえにする',
                    ),
                    SizedBox(
                      height: screen.designH(20),
                    ),
                    MyButton(
                        onPressed: _nurieImageBytes != null
                            ? () {
                                try {
                                  ImageGallerySaver.saveImage(
                                      _nurieImageBytes!);
                                } catch (e) {
                                  throw 'cannot save image';
                                }
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Center(
                                  child: Text(
                                    'アルバムにほぞんしました',
                                    style: TextStyle(
                                        fontSize: 24, fontFamily: mainFont),
                                  ),
                                )));
                              }
                            : null,
                        title: 'ほぞんする')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickButtonList(Screen screen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ImagePickButton(
            onPressed: () => _getImageFromDevice(ImageSource.camera),
            title: "カメラ",
            icon: const Icon(Icons.camera_enhance)),
        ImagePickButton(
            onPressed: () => _getImageFromDevice(ImageSource.gallery),
            title: "アルバム",
            icon: const Icon(Icons.photo_album))
      ],
    );
  }
}

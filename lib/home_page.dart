import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurie_3/constants.dart';
import 'package:nurie_3/button_widget/line_thickness_button.dart';
import 'package:nurie_3/default_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:nurie_3/button_widget/image_pick_button.dart';
import 'package:nurie_3/screen_pod.dart';
import 'package:path_provider/path_provider.dart';

import 'button_widget/save_or_convert_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isRotated = false;
  bool nurieCompleted = false;
  bool isProccessing = false;
  bool isLineTicknessChanging = false;
  File? _image;
  Uint8List? _originalImageBytes, _nurieImageBytes;

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
    if (pickedFile == null) return;

    _image = File(pickedFile.path);
    _originalImageBytes = await _image!.readAsBytes();

    // Exif情報により画像が回転しているか調べて、回転していたらRotatedBoxで元に戻す
    final tags = await readExifFromBytes(_originalImageBytes!);
    isRotated =
        tags["Image Orientation"].toString() == "Rotated 90 CW" ? true : false;
        
    // FadeAnimationをリセット
    _controller.reset();
    
    setState(() {
      nurieCompleted = false;
      _nurieImageBytes = null;
      _originalImageBytes;
    });
  }

  _imageConvert(String methodName, Uint8List imageBytes) async {
    isProccessing = true;
    final directory = await getTemporaryDirectory();
    final tempImagePath = '${directory.path}/temp.jpeg';
    File tempFile = File(tempImagePath);
    var imageFile = await tempFile.writeAsBytes(imageBytes);
    try {
      _nurieImageBytes =
          await nurieChannel.invokeMethod(methodName, imageFile.path);
    } catch (e) {
      throw 'error';
    }

    setState(() {
      _nurieImageBytes;
    });

    // ぬりえにした後FadeAnimationが終わってから、保存ボタンを活性化
    if (imageBytes == _originalImageBytes && !isLineTicknessChanging) {
      await Future.delayed(const Duration(milliseconds: 2000));
    }

    setState(() {
      nurieCompleted = true;
      isProccessing = false;
      isLineTicknessChanging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenRef(context).watch(screenProvider);
    final sizeClass = screen.sizeClass;
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: screen.designH(100)),
                      Stack(
                        children: [
                          _nurieImageBytes != null
                              ? RotatedBox(
                                  key: const Key('nurieImage'),
                                  quarterTurns: isRotated ? 1 : 0,
                                  child: Image.memory(
                                    key: const Key('nurieImage'),
                                    _nurieImageBytes!,
                                    width: screen.designW(400),
                                    height: screen.designH(400),
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const SizedBox(),
                          FadeTransition(
                            opacity: _animation,
                            child: SizedBox(
                                width: screen.designW(400),
                                height: screen.designH(400),
                                child: _originalImageBytes != null
                                    ? Image.memory(
                                        key: const Key('originalImage'),
                                        _originalImageBytes!,
                                        fit: BoxFit.contain,
                                      )
                                    : SizedBox(
                                        key: const Key('beforeOriginalImage'),
                                        width: screen.designW(400),
                                        height: screen.designH(400),
                                        child: const DefaultImage())),
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
                      nurieCompleted
                          ? Column(
                              children: [
                                Center(
                                    child: Text(
                                  'せんのふとさ',
                                  style: TextStyle(
                                      fontSize:
                                          sizeClass == ScreenSizeClass.phone
                                              ? 24
                                              : 48,
                                      letterSpacing: 4),
                                )),
                                SizedBox(
                                  height: screen.designH(10),
                                ),
                                _lineThicknessButtonList(screen, sizeClass)
                              ],
                            )
                          : SaveOrConvertButton(
                              onPressed:
                                  _originalImageBytes == null || isProccessing
                                      ? null
                                      : () async {
                                          _imageConvert(
                                              "image2NurieKernelSize10",
                                              _originalImageBytes!);
                                          _controller.forward();
                                        },
                              title: 'ぬりえにする',
                              color: imgConvertBtnColor,
                            ),
                      SizedBox(
                        height: screen.designH(20),
                      ),
                      SaveOrConvertButton(
                        onPressed: nurieCompleted
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
                                    style: TextStyle(fontSize: 24),
                                  ),
                                )));
                              }
                            : null,
                        title: 'ほぞんする',
                        color: imgSaveBtnColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            onPressed: isProccessing
                ? null
                : () {
                    _getImageFromDevice(ImageSource.camera);
                  },
            title: "カメラ",
            icon: const Icon(Icons.camera_enhance)),
        ImagePickButton(
            key: const Key('albumPickButton'),
            onPressed: isProccessing
                ? null
                : () {
                    _getImageFromDevice(ImageSource.gallery);
                  },
            title: "アルバム",
            icon: const Icon(Icons.photo_album))
      ],
    );
  }

  Widget _lineThicknessButtonList(Screen screen, ScreenSizeClass sizeClass) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            width: screen.designW(100),
            height: screen.designH(50),
            child: LineThicknessButton(
                onPressed: isProccessing
                    ? null
                    : () {
                        isLineTicknessChanging = true;
                        _imageConvert(
                            'image2NurieKernelSize5', _originalImageBytes!);
                      },
                fontSize: sizeClass == ScreenSizeClass.phone ? 18 : 36,
                title: 'ほそく')),
        SizedBox(
            width: screen.designW(100),
            height: screen.designH(50),
            child: LineThicknessButton(
                onPressed: isProccessing
                    ? null
                    : () {
                        isLineTicknessChanging = true;
                        _imageConvert(
                            'image2NurieKernelSize10', _originalImageBytes!);
                      },
                fontSize: sizeClass == ScreenSizeClass.phone ? 18 : 36,
                title: 'ふつう')),
        SizedBox(
            width: screen.designW(100),
            height: screen.designH(50),
            child: LineThicknessButton(
                onPressed: isProccessing
                    ? null
                    : () {
                        isLineTicknessChanging = true;
                        _imageConvert(
                            'image2NurieKernelSize15', _originalImageBytes!);
                      },
                fontSize: sizeClass == ScreenSizeClass.phone ? 18 : 36,
                title: 'ふとく')),
      ],
    );
  }
}

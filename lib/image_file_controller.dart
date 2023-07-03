import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


class ImageFileController {
  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future getAndSaveImageFromDevice(ImageSource source) async {
    // ignore: invalid_use_of_visible_for_testing_member
    PickedFile? imageFile = await ImagePicker.platform.pickImage(
        source: source);
    if (imageFile == null) {
      return;
    }
    var savedFile = saveImage(imageFile);
    return savedFile;
  }

  static Future saveImage(PickedFile image) async {
    final path = await localPath;
    final imagePath = '$path/temp.jpeg';
    File tempFile = File(imagePath);
    var savedFile = await tempFile.writeAsBytes(await image.readAsBytes());
    return savedFile;
  }

  static void deleteImageFile(String imageFileName) async {
    final path = await localPath;
    final imagePath = '$path/$imageFileName.jpeg';
    try {
      final imageFile = File(imagePath);
      await imageFile.delete();
    } catch (e) {
      return;
    }
  }
}
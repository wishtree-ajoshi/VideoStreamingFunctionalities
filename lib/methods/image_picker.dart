import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageSelector {
  Future<String> getFilePath(imageUrl) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String imageType = imageUrl.split('.').last;
    String filePath = '$appDocumentsPath/image_${DateTime.now()}.$imageType';
    return filePath;
  }

  Future pickImageGallery(imageUrl, _image) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      imageUrl = image.path;
      imageUrl = await getFilePath(imageUrl);
      image.saveTo(imageUrl);
      return imageUrl;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageCamera(imageUrl, _image) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      imageUrl = image.path;
      imageUrl = await getFilePath(imageUrl);
      image.saveTo(imageUrl);
      return imageUrl;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
}

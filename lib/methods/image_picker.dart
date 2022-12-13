import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
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

  Future pickImageCamera(imageUrl, image) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        print("image null");
        return '';
      } else {
        print("/*/*/*/*/* ${image.path}");
        imageUrl = image.path;
        imageUrl = await getFilePath(imageUrl);
        image.saveTo(imageUrl);
        return imageUrl;
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageGallery(imageUrl, image) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return '';
      } else {
        imageUrl = image.path;
        imageUrl = await getFilePath(imageUrl);
        image.saveTo(imageUrl);
        return imageUrl;
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future cropImage(imageUrl) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageUrl,
      cropStyle: CropStyle.rectangle,
      compressQuality: 100,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(

            //toolbarColor: Colors.deepOrange,
            //toolbarWidgetColor: Colors.white,
            //initAspectRatio: CropAspectRatioPreset.original,
            //lockAspectRatio: false
            ),
        IOSUiSettings(),
      ],
    );
    if (croppedFile != null) {
      return croppedFile;
    } else {
      return null;
    }
  }
}

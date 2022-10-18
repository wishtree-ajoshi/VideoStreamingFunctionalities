import 'dart:io';
import 'package:demo_app/methods/encryption_decryption.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DownloadVideo extends ChangeNotifier {
  double progress = 0;
  downloadVideo({
    required url,
    required saveFile,
    required fileName,
    required directory,
  }) async {
    try {
      await Dio().download(url, saveFile.path,
          onReceiveProgress: (value1, value2) {
        progress = value1 / value2;
        notifyListeners();
      });
      if (Platform.isIOS) {
        await ImageGallerySaver.saveFile(saveFile.path,
            isReturnPathOfIOS: true);
      }
      if (progress == 1) {
        try {
          File file = await EncryptionDecryption()
              .encryptFile("${directory.path}/$fileName");
          File(saveFile.path).delete();
          if (Platform.isIOS) {
            await ImageGallerySaver.saveFile(saveFile.path,
                isReturnPathOfIOS: true);
          }
          return file;
        } catch (e) {
          print(e);
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}

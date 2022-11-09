import 'dart:io';
import 'package:demo_app/methods/download_video.dart';
import 'package:demo_app/methods/request_permissions.dart';
import 'package:demo_app/methods/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StoreVideo {
  bool isDownloaded = false;
  File? downloadedFile;
  Future<bool> saveVideo({
    required String url,
    required String fileName,
    required int id,
  }) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await RequestPermissions().checkPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
        } else {
          return false;
        }
      } else {
        if (await RequestPermissions().checkPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        if (await File("${directory.path}/$fileName.aes").exists()) {
          return false;
        }
        File saveFile = File("${directory.path}/$fileName");
        downloadedFile = await DownloadVideo().downloadVideo(
          url: url,
          saveFile: saveFile,
          directory: directory,
          fileName: fileName,
        );
        if (downloadedFile != null) {
          await HiveDb.addVideoToList(key: id, value: downloadedFile!.path);
          id = id + 1;
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}

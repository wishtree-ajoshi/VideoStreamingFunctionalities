import 'package:demo_app/methods/request_permissions.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadUsingFlutterDownloader {
  downloadVideo({required url}) async {
    final status =
        await RequestPermissions().checkPermission(Permission.storage);
    if (status) {
      final externalDir = await getExternalStorageDirectory();
      try {
        final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: externalDir!.path,
          openFileFromNotification: false,
          showNotification: true,
          fileName: "${DateTime.now()}",
        ).onError((error, stackTrace) => null);
        print("*-*-taskId*-*-*-*-*-*-*-*-*$taskId");
        final path = "${externalDir.path}/$taskId";
        print("......................$path");
        return [
          taskId,
          path,
        ];
      } catch (e) {
        print("***+*+*+*+*+*+*+*+*++*+*+*+*+*+*+*+*+*$e");
        return null;
      }
    } else {
      return null;
    }
  }

  pauseVideo({required taskId}) async {
    try {
      await FlutterDownloader.pause(taskId: taskId).whenComplete(() {
        true;
      }).onError((error, stackTrace) => null);
    } catch (e) {
      print("***+*+*+*+*+*+*+*+*++*+*+*+*+*+*+*+*+*$e");
      return null;
    }
  }
}

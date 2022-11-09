import 'package:demo_app/methods/request_permissions.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadUsingFlutterDownloader {
  downloadVideo({required url, id}) async {
    final status =
        await RequestPermissions().checkPermission(Permission.storage);
    if (status) {
      final externalDir = await getExternalStorageDirectory();
      try {
        final nos = await FlutterDownloader.enqueue(
          url: url,
          savedDir: externalDir!.path,
          openFileFromNotification: false,
          showNotification: false,
          saveInPublicStorage: false,
          fileName: "Video_$id.mp4",
        );
        print("*-*-taskId*-*-*-*-*-*-*-*-*$nos");
        return nos;
      } catch (e) {
        print("***+*+*+*+*+*+*+*+*++*+*+*+*+*+*+*+*+*$e");
        return null;
      }
    } else {
      return null;
    }
  }
}

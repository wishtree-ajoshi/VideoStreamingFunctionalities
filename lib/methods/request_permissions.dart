import 'package:permission_handler/permission_handler.dart';

class RequestPermissions {
  Future<bool> checkPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else if (await permission.isDenied) {
      print("denied");
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
      openAppSettings();
      return false;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
}

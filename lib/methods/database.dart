import 'package:hive/hive.dart';

class HiveDb {
  static Box? videoList;

  createBox() async {
    videoList = await Hive.openBox('videoList');
  }

  static Future addVideoToList({key, value}) async {
    videoList?.put(key, value);
  }

  static Future<dynamic> getVideoList() async {
    return videoList?.toMap();
  }

  static deleteDataAt(key) async {
    videoList?.delete(key);
  }

  static deleteData() async {
    videoList?.clear();
  }
}

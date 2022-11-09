import 'package:demo_app/screens/main_page.dart';
import 'package:demo_app/methods/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );
  await Hive.initFlutter();
  await HiveDb().createBox();
  videoList = await initialListLoad();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

Map videoList = {};

initialListLoad() async {
  return (await HiveDb.getVideoList() != null)
      ? await HiveDb.getVideoList()
      : {};
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainPage(videoList: videoList),
    );
  }
}

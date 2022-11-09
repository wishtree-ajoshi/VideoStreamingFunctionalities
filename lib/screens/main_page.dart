import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:demo_app/methods/check_internet.dart';
import 'package:demo_app/methods/download_using_flutter_downloader.dart';
import 'package:demo_app/methods/encryption_decryption.dart';
import 'package:demo_app/screens/full_screen.dart';
import 'package:demo_app/methods/download_video.dart';
import 'package:demo_app/methods/store_video.dart';
import 'package:demo_app/screens/saved_videos_screen.dart';
import 'package:demo_app/methods/database.dart';
import 'package:demo_app/screens/upload_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MainPage extends StatefulWidget {
  MainPage(
      {super.key,
      required this.videoList,
      this.offline = false,
      this.filePath = ''});
  Map videoList;
  bool offline;
  String filePath;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late VideoPlayerController controller;
  bool isVisible = true;
  int id = 0;
  Timer? timer;
  bool internet = false;
  bool loading = false;
  int progress = 0;
  String url =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4';
  Map data = {};
  final ReceivePort _port = ReceivePort();

  ///Function to download and save a video to files in encrypted format...
  downloadFile() async {
    setState(() {
      loading = true;
      progress = 0;
    });

    /// saveVideo will download and save file to Device and will return a boolean
    /// for if the file is successfully or not

    final taskId =
        await DownloadUsingFlutterDownloader().downloadVideo(url: url, id: id);

    // bool downloaded = await StoreVideo().saveVideo(
    //   url: url,
    //   fileName: "Video_$id.mp4",
    //   id: id,
    // );

    if (await taskId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 200,
          backgroundColor: Colors.red.withOpacity(0.7),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          content: const Text(
            "File Downloaded",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (await taskId == null) {
      await HiveDb.addVideoToList(key: id, value: taskId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 200,
          backgroundColor: Colors.red.withOpacity(0.7),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50))),
          content: const Text(
            "Error Downloading File",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    widget.videoList = await HiveDb.getVideoList();
    if (await taskId != null) {
      id = id + 1;
    }
    print(id);
    print("///videoList//////${widget.videoList}");
    getData();
    setState(() {
      loading = false;
    });
  }

  ///Function to delete all the videos downloaded and clearing the database...
  onClearAll() async {
    if (widget.videoList.isNotEmpty) {
      for (int i = 0; i < widget.videoList.length; i++) {
        if (await File("${widget.videoList[i]}").exists()) {
          await File("${widget.videoList[i]}").delete();
        }
      }
    }
    id = 0;
    await HiveDb.deleteData();
    if (mounted) {
      setState(() {});
    }
    widget.videoList = await HiveDb.getVideoList();
    print(widget.videoList);
  }

  ///Function to hide overlay automatically
  visibilityOnOff() {
    timer?.cancel();
    setState(() {
      isVisible = true;
    });
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        isVisible = false;
        timer?.cancel();
      });
    });
  }

  ///Delete the saved videos...
  deleteVideo(index) async {
    if (await File("${data[index]}").exists()) {
      await File("${data[index]}").delete();
    }
    await HiveDb.deleteDataAt(index);
    data = await HiveDb.getVideoList();
    id = id - 1;
    print(id);
    getData();
    if (mounted) {
      setState(() {});
    }
  }

  ///On clicking the tile of saved videos...
  onTilePressed({
    required int index,
  }) async {
    if (await File(data[index]).exists()) {
      File file = await EncryptionDecryption().decryptFile(data[index]);
      print("***********${file.path}");

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              videoList: data,
              filePath: file.path,
              offline: true,
            ),
          ));
    }
  }

  getData() async {
    data = await HiveDb.getVideoList();
    id = data.length;
    if (mounted) {
      setState(() {});
    }
  }

  checkInternet() async {
    internet = await CheckInternet().checkConnection();
    if (mounted) {
      setState(() {
        print(internet);
      });
    }
  }

  @override
  void initState() {
    checkInternet();
    getData();
    controller = (widget.offline == true)
        ? VideoPlayerController.file(File(widget.filePath))
        : VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    id = (widget.videoList.isEmpty) ? 0 : widget.videoList.length;
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      print("//data///////////$data");
      String id = data[0];
      DownloadTaskStatus status = data[1];
      progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    print("/id/*/*//*/*//*/* $id");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Streaming"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(children: [
                  GestureDetector(
                    onTap: (() {
                      visibilityOnOff();
                    }),
                    onDoubleTap: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                    child: (controller.value.isInitialized && internet == true)
                        ? AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(children: [
                              VideoPlayer(controller),

                              ///Hide overlay after few seconds...
                              Visibility(
                                visible: isVisible,

                                ///Stick overlay to bottom of video player...
                                child: Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: VideoProgressIndicator(
                                          controller, //video player controller
                                          allowScrubbing: true,
                                          colors: const VideoProgressColors(
                                            //video player progress bar
                                            backgroundColor: Colors.black12,
                                            playedColor: Colors.red,
                                            bufferedColor: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                setState(() {
                                                  visibilityOnOff();
                                                  controller.seekTo(
                                                    Duration(
                                                        seconds: controller
                                                                .value
                                                                .position
                                                                .inSeconds -
                                                            10),
                                                  );
                                                });
                                              },
                                              iconStyle:
                                                  Icons.replay_10_rounded),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                visibilityOnOff();
                                                setState(() {
                                                  controller.value.isPlaying
                                                      ? controller.pause()
                                                      : controller.play();
                                                });
                                              },
                                              iconStyle: (controller
                                                      .value.isPlaying)
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                visibilityOnOff();
                                                setState(() {
                                                  controller.seekTo(
                                                    Duration(
                                                        seconds: controller
                                                                .value
                                                                .position
                                                                .inSeconds +
                                                            10),
                                                  );
                                                });
                                              },
                                              iconStyle:
                                                  Icons.forward_10_rounded),
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          videoPlayerButtons(
                                              onButtonTap: () {
                                                setState(() {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullScreen(
                                                              controller:
                                                                  controller),
                                                    ),
                                                  );
                                                });
                                              },
                                              iconStyle:
                                                  Icons.fullscreen_rounded),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]))
                        :

                        ///For  no internet and uninitialized video player..
                        AspectRatio(
                            aspectRatio: 2,
                            child: Container(
                              color: Colors.black,
                              width: double.infinity,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Looks like there was some issue..please try reloading",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    IconButton(
                                      onPressed: (() async {
                                        await checkInternet();
                                        if (internet == true) {
                                          controller =
                                              VideoPlayerController.network(url)
                                                ..initialize().then((_) {
                                                  // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                                  setState(() {});
                                                });
                                        }
                                      }),
                                      icon: const Icon(Icons.replay_outlined),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),

                  ///Download and other buttons...
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ///Download Button...
                      IconButton(
                        icon: const Icon(
                          size: 35,
                          Icons.download_rounded,
                        ),
                        color: Colors.red,
                        onPressed: downloadFile,
                        padding: const EdgeInsets.all(10),
                      ),

                      /// Saved Videos Page Route...
                      // MaterialButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => SavedVideos(id: id),
                      //       ),
                      //     );
                      //   },
                      //   color: Colors.red,
                      //   child: const Text(
                      //     "Saved Videos",
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),

                      ///Clear all videos
                      IconButton(
                        onPressed: () async {
                          await onClearAll();
                        },
                        iconSize: 35,
                        color: Colors.red,
                        icon: const Icon(Icons.clear_all_rounded),
                      ),
                    ],
                  ),
                  (loading)
                      ? Consumer(
                          builder:
                              (BuildContext context, value, Widget? child) =>
                                  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: progress.toDouble(),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  (widget.offline == true)
                      ? const Text("Offline Mode")
                      : const SizedBox(),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadFile(),
                        ),
                      );
                    },
                    color: Colors.red,
                    child: const Text(
                      "Upload File",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ])),
          ),
          (data.isNotEmpty)
              ? Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: (data.isEmpty) ? 0 : data.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(2),
                      child: ListTile(
                        trailing: IconButton(
                            onPressed: () async {
                              await deleteVideo(index);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                            )),
                        shape: Border.all(width: 0.7, color: Colors.black),
                        tileColor: Colors.redAccent,
                        onTap: () {
                          onTilePressed(index: index);
                        },
                        title: Text("${data[index]}"),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    "No videos saved",
                  ),
                ),
          Container(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black))),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SizedBox(child: Text("I need help")),
                  Text("I understand"),
                ],
              )),
        ],
      ),
    );
  }
}

Widget videoPlayerButtons(
    {required Function() onButtonTap, required iconStyle}) {
  return IconButton(
    onPressed: () {
      onButtonTap();
    },
    icon: Icon(iconStyle),
    iconSize: 35,
    color: Colors.white.withOpacity(0.8),
  );
}

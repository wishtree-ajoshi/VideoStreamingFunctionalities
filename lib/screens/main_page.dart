import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:demo_app/methods/check_internet.dart';
import 'package:demo_app/methods/download_using_flutter_downloader.dart';
import 'package:demo_app/screens/doc_viewer.dart';
import 'package:demo_app/screens/full_screen.dart';
import 'package:demo_app/methods/database.dart';
import 'package:demo_app/screens/qr_scanner.dart';
import 'package:demo_app/screens/quiz_page.dart';
import 'package:demo_app/screens/upload_file.dart';
import 'package:demo_app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MainPage extends StatefulWidget {
  MainPage(
      {super.key,
      required this.videoList,
      required this.taskList,
      this.offline = false,
      this.filePath = ''});
  Map videoList;
  List taskList;
  bool offline;
  String filePath;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late VideoPlayerController controller;
  bool isVisible = true;

  ///Timer for changing visibility of overlay
  Timer? timer;

  bool tapped = false;
  bool internet = false;
  bool loading = false;
  int progress = 0;
  String url =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4';

  ///Map of all videos downloaded..
  Map data = {};

  ///List of taskID ..i.e keys of VideoMap
  List taskList = [];

  final ReceivePort _port = ReceivePort();

  ///Function to download and save a video to files in encrypted format...
  downloadFile() async {
    if (mounted) {
      setState(() {
        loading = true;
        progress = 0;
      });
    }

    /// saveVideo will download and save file to Device and will return a boolean for if the file is successfully or not

    final result =
        await DownloadUsingFlutterDownloader().downloadVideo(url: url);

    if (await result != null) {
      final taskId = await result[0];
      final filePath = await result[1];

      // bool downloaded = await StoreVideo().saveVideo(
      //   url: url,
      //   fileName: "Video_$id.mp4",
      //   id: id,
      // );

      if (await result != null) {
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

      if (await result == null) {
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
        loading = false;
        return null;
      }
      taskList.add(taskId);
      await HiveDb.addVideoToList(key: taskId, value: filePath);
      data = await HiveDb.getVideoList();
      print("///data//////$data");
      widget.videoList = data;
      print("data is ......$data");
      print("taskList is ......$taskList");
    }
    print("///videoList//////${widget.videoList}");
    getData();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  ///Function to delete all the videos downloaded and clearing the database...
  onClearAll() async {
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        if (await File("${data[i]}").exists()) {
          await FlutterDownloader.remove(
              taskId: taskList[i], shouldDeleteContent: true);
          await File("${data[i]}").delete();
        }
      }
    }
    await HiveDb.deleteData();
    if (mounted) {
      setState(() {});
    }
    getData();
  }

  ///Function to hide overlay automatically
  visibilityOnOff() {
    timer?.cancel();
    if (mounted) {
      setState(() {
        isVisible = true;
      });
    }
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          isVisible = false;
          timer?.cancel();
        });
      }
    });
  }

  ///Delete the saved videos...

  deleteVideo(index) async {
    await FlutterDownloader.remove(
        taskId: taskList[index], shouldDeleteContent: true);
    await HiveDb.deleteDataAt(taskList[index]);
    await getData();
    if (mounted) {
      setState(() {});
    }
  }

  ///On clicking the tile of saved videos...
  onTilePressed({
    required int index,
  }) async {
    print("data is ......$data");
    print("taskList is ......$taskList");
    print("data at index: $index..${taskList[index]}");

    FlutterDownloader.open(taskId: taskList[index]);

    // if (await File(data[index]).exists()) {
    //   File file = await EncryptionDecryption().decryptFile(data[index]);
    //   print("***********${file.path}");

    //   Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => MainPage(
    //           videoList: data,
    //           filePath: file.path,
    //           offline: true,
    //         ),
    //       ));
    // }
  }

  ///Function to check internet and reload when internet is back again...
  onReload() async {
    await checkInternet();
    if (internet == true) {
      controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          if (mounted) {
            setState(() {});
          }
        });
    }
  }

  ///Function to play or pause the video...
  playPause() {
    if (mounted) {
      setState(() {
        controller.value.isPlaying ? controller.pause() : controller.play();
      });
    }
  }

  ///Function to skip 10s backwards...
  onBackward10() {
    setState(() {
      visibilityOnOff();
      controller.seekTo(
        Duration(seconds: controller.value.position.inSeconds - 10),
      );
    });
  }

  ///Function to skip 10s forward...
  onForward10() {
    if (mounted) {
      setState(() {
        visibilityOnOff();
        controller.seekTo(
          Duration(seconds: controller.value.position.inSeconds + 10),
        );
      });
    }
  }

  ///Navigate to a full screen page for video player...
  onFullScreen() {
    if (mounted) {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreen(controller: controller),
          ),
        );
      });
    }
  }

  ///Pause downloading....
  onDownloadPause(taskId) async {
    await DownloadUsingFlutterDownloader().pauseVideo(taskId: taskId);
  }

  onDocumentViewerClick() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DocViewer(),
        ));
  }

  onQuizPageClick() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizPage(),
        ));
  }

  getData() async {
    data = await HiveDb.getVideoList();
    taskList = await HiveDb.getTaskList();
    print("getData......////....$data");
    print("getData......////....$taskList");
    if (mounted) {
      setState(() {});
    }
  }

  checkInternet() async {
    internet = await CheckInternet().checkConnection();
    if (mounted) {
      setState(() {
        print("internet status........../// $internet");
      });
    }
  }

  ///Function to convert the duration of video...
  String videoDuration(Duration duration) {
    String hh(int n) => n.toString().padLeft(2, "0");
    String mm = hh(duration.inMinutes.remainder(60));
    String ss = hh(duration.inSeconds.remainder(60));
    if (hh(duration.inHours) == "00") {
      return "$mm:$ss";
    } else {
      return "${hh(duration.inHours)}:$mm:$ss";
    }
  }

  onQRScanClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScanner(),
      ),
    );
  }

  ///Init State
  @override
  void initState() {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    checkInternet();
    data = widget.videoList;
    taskList = widget.taskList;
    getData();
    controller = (widget.offline == true)
        ? VideoPlayerController.file(File(widget.filePath))
        : VideoPlayerController.network(url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if (mounted) {
          setState(() {});
        }
      });
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      if (mounted) {
        setState(() {
          progress = data[2];
        });
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static downloadCallback(String id, DownloadTaskStatus status, int progress) {
    SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port') as SendPort;
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.white,
          elevation: 10,
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => onQRScanClick(),
                  child: const Text("QR Scanner"),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text("Video Streaming"),
          centerTitle: true,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: (() {
                        visibilityOnOff();
                      }),
                      onDoubleTap: () {
                        playPause();
                      },
                      child: (controller.value.isInitialized &&
                              internet == true)
                          ? Container(
                              color: Colors.black,
                              width: MediaQuery.of(context).size.width,
                              height:
                                  MediaQuery.of(context).size.width * 0.5625,
                              child: Stack(
                                children: [
                                  Center(
                                    child: AspectRatio(
                                      aspectRatio: controller.value.aspectRatio,
                                      child: VideoPlayer(controller),
                                    ),
                                  ),

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
                                          ///Duration of elapsed video to total video..
                                          ValueListenableBuilder(
                                            valueListenable: controller,
                                            builder: (context,
                                                VideoPlayerValue value, child) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "${videoDuration(controller.value.position)}/${videoDuration(controller.value.duration)}",
                                                    style: const TextStyle(
                                                        color: Colors.white70),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: VideoProgressIndicator(
                                              controller, //video player controller
                                              allowScrubbing: true,
                                              colors: const VideoProgressColors(
                                                //video player progress bar
                                                backgroundColor: Colors.black26,
                                                playedColor: Colors.red,
                                                bufferedColor: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              videoPlayerButtons(
                                                  onButtonTap: () {
                                                    visibilityOnOff();
                                                    onBackward10();
                                                  },
                                                  iconStyle:
                                                      Icons.replay_10_rounded),
                                              videoPlayerButtons(
                                                  onButtonTap: () {
                                                    visibilityOnOff();
                                                    playPause();
                                                  },
                                                  iconStyle: (controller
                                                          .value.isPlaying)
                                                      ? Icons.pause_rounded
                                                      : Icons
                                                          .play_arrow_rounded),
                                              videoPlayerButtons(
                                                  onButtonTap: () {
                                                    visibilityOnOff();
                                                    onForward10();
                                                  },
                                                  iconStyle:
                                                      Icons.forward_10_rounded),
                                              videoPlayerButtons(
                                                  onButtonTap: () {
                                                    onFullScreen();
                                                  },
                                                  iconStyle:
                                                      Icons.fullscreen_rounded),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          :

                          ///For  no internet and uninitialized video player..
                          GestureDetector(
                              onTap: (() async {
                                await onReload();
                              }),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  color: Colors.black,
                                  width: double.infinity,
                                  child: Center(
                                    child: (controller.value.isInitialized ||
                                            internet != true)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                "Please check your internet connection and retry...",
                                                style: TextStyle(
                                                    color: Colors.white),
                                                overflow: TextOverflow.visible,
                                              ),
                                              Icon(Icons.replay_outlined,
                                                  color: Colors.white),
                                            ],
                                          )
                                        : const CircularProgressIndicator(
                                            color: Colors.white54,
                                          ),
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
                          onPressed: () async => await downloadFile(),
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
                          onPressed: () async => await onClearAll(),
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
                                value: progress / 100,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    // (widget.offline == true)
                    //     ? const Text("Offline Mode")
                    //     : const SizedBox(),
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
                  ],
                ),
              ),
            ),
            (data.isNotEmpty)
                ? Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.only(bottom: 60),
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
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          tileColor: Colors.blueGrey,
                          onTap: () {
                            onTilePressed(index: index);
                          },
                          title: Text("${data[taskList[index]]}"),
                        ),
                      ),
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: Text(
                        "No videos saved",
                      ),
                    ),
                  ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, -2),
                      blurRadius: 5,
                      spreadRadius: 5)
                ],
                // border: Border(
                //   top: BorderSide(color: Colors.black),
                // ),
              ),
              padding: const EdgeInsets.all(10),
              height: 60,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => onQuizPageClick(),
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          // border: Border.all(
                          //   color: Colors.black,
                          //   width: 1,
                          // ),
                        ),
                        child: const Text("Take me to Quiz")),
                  ),
                  GestureDetector(
                    onTap: () => onDocumentViewerClick(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: const Text("Document viewer"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
